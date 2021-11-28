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
devvpc = "10.0.0.0/16"
vpc-tag = {
  name = "devvpc"
  env = "dev"
}
pri_subnet = "10.0.2.0/24"
pri_sub_tag = {
  name = "pri_sub"
  env = "dev"
}
devigw = {
  name = "devigw"
  env = "dev"
}
routetag = {
  name = "routedev"
  env = "dev"
}