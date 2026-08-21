variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "ami_id" {
  description = "Amazon Linux AMI ID for us-east-1"
  type        = string
}

variable "key_name" {
  description = "Name of existing AWS EC2 Key Pair"
  type        = string
}