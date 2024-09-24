# Variables defined externally for AWS credentials, region, and internal endpoint
variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"  # Default region, can be overridden
}

variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
  default     = "ami-0ebfd941bbafe70c6"
}

variable "instance_type" {
  description = "Type of the AWS EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name to use for the instance"
  type        = string
  default     = "admin-aws-converge-key"
}

variable "internal_aws_endpoint" {
  description = "Internal AWS service endpoint URL provided by the user"
  type        = string
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  # Custom endpoint for internal AWS link provided by the user
  endpoints {
    ec2 = var.internal_aws_endpoint  # Use the variable to set the custom EC2 endpoint
  }
}

# Create EC2 instances for Jenkins-Master, build-slave, and ansible
resource "aws_instance" "demo-server" {
  ami                    = var.ami_id  # AMI ID for your region
  instance_type          = var.instance_type  # Instance type
  key_name               = var.key_name  # SSH key pair name
  associate_public_ip_address = true  # Assign public IP for access

  for_each = toset(["Jenkins-Master", "build-slave", "ansible"])

  tags = {
    Name = each.key  # Tag each instance with its respective name
  }
}
