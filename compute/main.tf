#---compute/main.tf---

# EC2 Instance Image Template
data "aws_ami" "linux_ami" {
  most_recent = true

  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.*.0-x86_64-gp2"]
  }
}

# RANDOM NAMING SCHEME FOR WEBSERVER EC2 INSTANCES
resource "random_pet" "random" {}

# WEBSERVER INSTANCES LAUNCH TEMPLATE
resource "aws_launch_template" "krypt0_24_webserver" {
  name_prefix            = "krypt0_24_webserver-${random_pet.random.id}"
  image_id               = data.aws_ami.linux_ami.id
  instance_type          = var.krypt0_24_webserver_instance_type
  vpc_security_group_ids = [var.public_sg]
  key_name               = var.key_name
  user_data              = filebase64("userdata.sh")

  tags = {
    Name = "krypt0_24_webserver"
  }
}

# WEBSERVER AUTOSCALING GROUP
resource "aws_autoscaling_group" "krypt0_24_webserver" {
  name                = "krypt0_24_webserver-${random_pet.random.id}"
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2
  vpc_zone_identifier = tolist(var.public_subnet)

  launch_template {
    id      = aws_launch_template.krypt0_24_webserver.id
    version = "$Latest"
  }
}