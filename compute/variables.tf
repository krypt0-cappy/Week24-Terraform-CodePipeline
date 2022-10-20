#---compute/variables.tf---

variable "krypt0_24_webserver_instance_type" {
  type    = string
  default = "t3.micro"
}
variable "public_subnet" {}
variable "key_name" {}
variable "public_sg" {}
