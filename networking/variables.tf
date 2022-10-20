#---networking/variables.tf---

variable "vpc_cidr" {
  type = string
}

variable "public_cidrs" {
  type = list(any)
}

variable "access_ip" {
  type = string
}

variable "public_subnet_count" {
  default = 2
}