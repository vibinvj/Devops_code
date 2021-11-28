sgname = "testsg"
ipblock = ["0.0.0.0/0", "10.0.1.0/24"]
ins-tag = {
  name = "devinc"
  env = "dev"
  version = 1.0
}
devami = "ami-04ad2567c9e3d7893"
pub_subnet = "10.0.1.0/24"
ins_type = "t2.micro"
sg-tag = {
  name = "devsg"
  env = "dev"
}
pub-sub-tag = {
  name = "pub-sub"
  env = "dev"
}