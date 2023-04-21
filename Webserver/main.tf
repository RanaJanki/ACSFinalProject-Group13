# Terraform Config file (main.tf). This has provider block (AWS) and config for provisioning one EC2 instance resource.  

terraform {
required_providers {
  aws = {
  source = "hashicorp/aws"
  version = ">= 3.27"
 }
}

  required_version = ">=0.14"
} 
provider "aws" {
  profile = "default"
  region = "us-east-1"
}



# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "terraform_remote_state" "prod" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "acs730-p1"            // Bucket from where to GET Terraform State
    key    = "dev/network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                       // Region where bucket created
  }
}

# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env },{"Vishal" = var.Name})
  name_prefix  = "${var.prefix}-${var.env}"
  

}

resource "aws_instance" "pubvm" {
  count = length(data.terraform_remote_state.prod.outputs.public_subnet_id)
  #count = 3
  ami = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.week6.key_name
  subnet_id = data.terraform_remote_state.prod.outputs.public_subnet_id[count.index]
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/install_httpd.sh")
  tags                        = { Name = count.index == 1 ? "bastion" : "pubvm${count.index+1}", Owner= "Vishal" }
}


 
resource "aws_instance" "prvm" {
  count = length(data.terraform_remote_state.prod.outputs.private_subnet_id)
  ami = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.week6.key_name
  subnet_id = data.terraform_remote_state.prod.outputs.private_subnet_id[count.index]
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  user_data                   = file("${path.module}/install_httpd.sh")
  tags = {
    Name = "prvm${count.index + 1}",
    Owner= "Vishal"
  }
}


# Adding SSH  key to instance
resource "aws_key_pair" "week6" {
  key_name   = var.prefix
  public_key = file("week6.pub")
}



resource "aws_security_group" "private_sg" {
  name_prefix = "private-"
  vpc_id      = data.terraform_remote_state.prod.outputs.vpc_id

  
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
  from_port = 0
  to_port = 0
  protocol= "-1"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "private-sg"
  }
}




