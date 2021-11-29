resource "aws_vpc" "glb_vpc" {
  cidr_block = var.devvpc
  tags = var.vpc-tag
}
resource "aws_subnet" "glb_pub_sub" {
  cidr_block = var.pub_subnet
  vpc_id     = aws_vpc.glb_vpc.id
  tags = var.pub-sub-tag
}
resource "aws_subnet" "glb_pri_sub" {
  cidr_block = var.pri_subnet
  vpc_id     = aws_vpc.glb_vpc.id
  tags = var.pri_sub_tag
}

resource "aws_internet_gateway" "glb_igw" {
  vpc_id = aws_vpc.glb_vpc.id
  tags = var.devigw
}
resource "aws_route_table" "glb_route" {
  vpc_id = aws_vpc.glb_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.glb_igw.id
  }
  tags = var.routetag
}
resource "aws_route_table_association" "glb_RT_attach" {
  route_table_id = aws_route_table.glb_route.id
  subnet_id = aws_subnet.glb_pub_sub.id
}
resource "aws_eip" "glb_eip" {
  vpc = true
}
resource "aws_nat_gateway" "glb_nat" {
  allocation_id = aws_eip.glb_eip.id
  subnet_id = aws_subnet.glb_pri_sub.id
}
resource "aws_security_group" "glb_sg" {
  name = var.sgname
  vpc_id = aws_vpc.glb_vpc.id
  ingress {
    from_port = 22
    protocol  = "TCP"
    to_port   = 22
    cidr_blocks = var.ipblock
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.sg-tag
}
resource "aws_key_pair" "glb_keypair" {
  key_name   = "testvibin-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDTIvWNXuX50Q2VGQ0gV1/aWIGwySU9/bVvnewYnbHCI0ZANBo8MwAaAhWm4tmcQWl/SheHZDuJ8xHI/bf69x2DVQDP4Bqsrbxvm9kFUo+I0nXpJh3xKlk5pRf8VXX2u9V7vEpmynXYQMWI2PsiyTNYMqC33lgN0HLHUwLdwGcTGbUOeRdXkz5QA0EdO4Qfp2/xNTW4h2iwth+8ChTSVv8xbUcS96vpDyJnc+1ZHXL84aOQN7AESGbeup9dlJw2ydNfzuhz21JeEAlg2Jp7pB+96L55FB0sozw8AfddsSWUvCtASk6tSbCDTjQ5Z3brOXf12rR05/nz6qZqtvXMBW5M+/eql+ZQFusvTvDOAlVfQPfAdkMhEcoOdDRPsUNknkvzyu34UVjT3hAQdAYgDuaMAdcJLigVTwirFqGKHGAl/JTAOjBXzDzi9EFr+QumyvwY34+3aJkY7V6XCldYf73BW4z33HHpJ1XIjgIaBe0linZozdHRR0WhTMlez2ixiE8= HAI@DESKTOP-2KAJDDS"
}
resource "aws_instance" "glb_ins" {
  ami = var.devami
  instance_type = var.ins_type
  subnet_id = "${aws_subnet.glb_pub_sub.id}"
  private_ip = "10.0.1.10"
  vpc_security_group_ids = ["${aws_security_group.glb_sg.id}"]
  iam_instance_profile = aws_iam_instance_profile.glb_ins_profile.id
  associate_public_ip_address = true
  key_name = aws_key_pair.glb_keypair.key_name
#  security_groups = ["${aws_security_group.glb_sg.name}"]
  tags = var.ins-tag
}
resource "aws_instance" "glb_pri_ins" {
  ami = var.devami
  instance_type = var.ins_type
  subnet_id = "${aws_subnet.glb_pri_sub.id}"
  private_ip = "10.0.2.10"
#  vpc_security_group_ids = ["${aws_security_group.glb_sg.id}"]
  iam_instance_profile = aws_iam_instance_profile.glb_ins_profile.id
  key_name = aws_key_pair.glb_keypair.key_name
  security_groups = ["${aws_security_group.glb_sg.name}"]
  tags = {
    name = "private_ins"
    env = "dev"
  }
}

resource "aws_iam_role" "glb_ins_role" {
  name = "web_ins_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    name = "webrole"
    env = "dev"
  }
}

resource "aws_iam_policy_attachment" "glb_policy_attach" {
  name       = "remote-access"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  roles = ["${aws_iam_role.glb_ins_role.id}"]
}

resource "aws_iam_instance_profile" "glb_ins_profile" {
  name = "webprofile"
  role = aws_iam_role.glb_ins_role.name
}
