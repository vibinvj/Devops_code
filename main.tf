resource "aws_security_group" "global_sg" {
  name = var.sgname
  description = "allow ssh ports"
  vpc_id = aws_vpc.globalvpc.id
  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Terraform_SG"
    env = "devtestsg"
  }
}
resource "aws_vpc" "globalvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "testvpc"
    env = "dev"
  }
}
resource "aws_subnet" "glb_pub_sub" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.globalvpc.id
  tags = {
    Name = "Pri_Subnet"
  }
}

resource "aws_instance" "global_inc" {
  ami = "ami-04ad2567c9e3d7893"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.glb_ins_profile.id
  tags = {
    Name = "webinstance"
    env = "devinc"
  }
  security_groups = ["${aws_security_group.global_sg.name}"]
}

resource "aws_iam_role" "glb_iam_role" {
  name = "web_role"
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
    Name = "web-role"
  }
}
resource "aws_iam_policy_attachment" "glb_policy_attach" {
  name       = "policyattach"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  roles = ["${aws_iam_role.glb_iam_role.id}"]
}

resource "aws_iam_instance_profile" "glb_ins_profile" {
  name = "ins_profile"
  role = aws_iam_role.glb_iam_role.name
}