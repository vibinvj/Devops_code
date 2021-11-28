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
  security_groups = ["${aws_security_group.glb_sg.name}"]
  iam_instance_profile = aws_iam_instance_profile.glb_ins_profile.id
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