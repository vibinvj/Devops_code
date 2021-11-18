resource "aws_security_group" "global_sg" {
  name = "terraform_sg"
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
  availability_zone = "us-east-1a"
  vpc_id     = aws_vpc.globalvpc.id
  tags = {
    Name = "Pub_Subnet"
  }
}
resource "aws_subnet" "glb_pri_sub" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.globalvpc.id
  tags = {
    Name = "Pri_Subnet"
  }
}
resource "aws_network_interface" "glb_net" {
  subnet_id = aws_subnet.glb_pri_sub.id
  private_ip = "10.0.2.10"
}
resource "aws_instance" "global_inc" {
  ami = "ami-04ad2567c9e3d7893"
  instance_type = "t2.micro"
  tags = {
    Name = "webinstance"
    env = "devinc"
  }
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.glb_net.id
  }
}
