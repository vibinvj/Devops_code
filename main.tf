resource "aws_vpc" "globalvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "testvpc"
    env = "dev"
  }
}
