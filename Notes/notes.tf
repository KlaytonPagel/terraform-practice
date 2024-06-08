# This file is used for notes and examples about terraform

# -----------------Initial provider set up______________________________________________________________________________
# provider is the name of the service provider you are using
provider "aws" {
  region  = "us-east-1" # region is the aws region your service will be deployed in
  profile = "default"   # profile is the AWS credential profile being used
}

# _________________Create a VPC_________________________________________________________________________________________
resource "aws_vpc" "note-vpc" {
  cidr_block = "10.0.5.0/24"

  tags = {
    Name = "note-vpc"
  }
}

# __________________Internet Gateway for the VPC________________________________________________________________________
resource "aws_internet_gateway" "note-inet-gw" {
  vpc_id = aws_vpc.note-vpc.id

  tags = {
    Name = "note-inet-gw"
  }
}

# _________________First subnet for the VPC_____________________________________________________________________________
resource "aws_subnet" "note-subnet-1" {
  vpc_id     = aws_vpc.note-vpc.id
  cidr_block = "10.0.5.0/26"

  tags = {
    Name = "note-subnet-1"
  }
}

# _________________Security group for the VPC to allow SSH______________________________________________________________
resource "aws_security_group" "note-sec-group-allow-ssh" {
  name        = "note-sec-group-allow-ssh"
  description = "Allows SSH connections"
  vpc_id      = aws_vpc.note-vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = [aws_subnet.note-subnet-1.cidr_block]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "note-sec-group-allow-ssh"
  }
}

# _________________Route table for the VPC traffic______________________________________________________________________
resource "aws_route_table" "note-route-table" {
  vpc_id = aws_vpc.note-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.note-inet-gw.id
  }

  tags = {
    Name = "note-route-table"
  }
}

# _________________Associating the subnet and the route table together__________________________________________________
resource "aws_route_table_association" "note-subnet-1-association" {
  route_table_id = aws_route_table.note-route-table.id
  subnet_id      = aws_subnet.note-subnet-1.id
}

# _________________Network interface for the EC2 instance_______________________________________________________________
resource "aws_network_interface" "note-server-1-nic" {
  subnet_id = aws_subnet.note-subnet-1.id
  private_ips = ["10.0.5.10"]
  security_groups = [aws_security_group.note-sec-group-allow-ssh.id]
}

# _________________Elastic IP for the EC2 instance______________________________________________________________________
resource "aws_eip" "note-server-1-eip" {
  domain = "vpc"
  network_interface = aws_network_interface.note-server-1-nic.id
}

# _________________Deploy an EC2 instance with the debian image and the t2.micro instance type__________________________
resource "aws_instance" "note-server-1" {
  ami           = "ami-058bd2d568351da34"
  instance_type = "t2.micro"
  key_name = "note-server-1"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.note-server-1-nic.id
  }

  tags = {
    Name = "note-server-1"
  }
}