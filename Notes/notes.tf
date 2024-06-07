# This file is used for notes about terraform

# -----------------Initial provider set up______________________________________________________________________________
# provider is the name of the service provider you are using
provider "aws" {
  region = "us-east-1" # region is the aws region your service will be deployed in
  profile = "default" # profile is the AWS credential profile being used
}


# _________________Deploy an EC2 instance with the debian image and the t2.micro instance type__________________________
# resource is the type of service you are deploying
# resource "<provider>_<resource type>" "<Name>" {
resource "aws_instance" "app_server" {

  # AMI is the amazon machine image used
  ami           = "ami-058bd2d568351da34"

  # Instance type is the machine specifications as shown in AWS
  instance_type = "t2.micro"
}