provider "aws" {
  region     = "us-east-1"
}

# Create the EC2 instances for Jenkins-Master, build-slave, and ansible
resource "aws_instance" "demo-server" {
  ami                    = "ami-0ebfd941bbafe70c6"  # AMI ID for your region
  instance_type          = "t2.micro"  # Instance type
  key_name               = "admin-aws-converge-key"  # Your SSH key pair name
  associate_public_ip_address = true  # Assign public IP for access

  for_each = toset(["Jenkins-Master", "build-slave", "ansible"])

  tags = {
    Name = each.key  # Tag each instance with its respective name
  }
}
