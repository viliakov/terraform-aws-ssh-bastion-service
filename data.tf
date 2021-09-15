##########################
# Query AWS Region
##########################
data "aws_region" "current" {
}


##########################
# Query AWS Account ID
##########################
data "aws_caller_identity" "current" {}

##########################
# Query for most recent AMI of type Ubuntu
##########################
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}
