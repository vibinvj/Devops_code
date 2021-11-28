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
resource "aws_eip" "glb_eip" {}
resource "aws_nat_gateway" "glb_nat" {
  allocation_id = aws_eip.glb_eip.id
  subnet_id = aws_subnet.glb_pri_sub.id
}
resource "aws_security_group" "glb_sg" {
  name = var.sgname
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
resource "aws_instance" "glb_ins" {
  ami = var.devami
  instance_type = var.ins_type
  iam_instance_profile = aws_iam_instance_profile.glb_ins_profile.id
  security_groups = ["${aws_security_group.glb_sg.name}"]
  tags = var.ins-tag
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