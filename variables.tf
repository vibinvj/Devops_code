variable "sgname" {
  description = "this is test variable"
  default = "prodsg"
}
variable "ipblock" {
  description = "this is to allow server remote"
  type = list(string)
  default = ["0.0.0.0/16", "192.168.0.0/16"]
}
variable "ins-tag" {
  description = "instance tag declare"
  type = object({
    name = string
    env = string
    version = number
  })
}
variable "devami" {
  description = "test declare ami"
  type = string
}
variable "pub_subnet" {
  description = "pub sub"
  type = string
}
variable "pri_subnet" {
  description = "pri sub"
  type = string
}

variable "pri_sub_tag" {
  description = "tag pri"
  type = object({
    name = string
    env = string
  })
}

variable "ins_type" {
  description = "declare ins type"
  type = string
}
variable "sg-tag" {
  description = "declare sg tags"
  type = object({
    name = string
    env = string
  })
}
variable "pub-sub-tag" {
  description = "tag for pub sub"
  type = object({
    name = string
    env = string
  })
}
variable "devvpc" {
  description = "dev vpc"
  type = string
}
variable "vpc-tag" {
  description = "vpc tag"
  type = object({
    name = string
    env = string
  })
}

variable "devigw" {
  description = "dev igw"
  type = object({
    name = string
    env = string
  })
}
variable "routetag" {
  description = "route tag"
  type = object({
    name = string
    env = string
  })
}
