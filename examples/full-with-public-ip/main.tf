provider "aws" {
  region = var.aws-region
}

data "aws_availability_zones" "available" {
}

resource "aws_vpc" "bastion" {
  cidr_block           = "${var.cidr-start}.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "bastion-${var.environment-name}-vpc"
  }
}

resource "aws_subnet" "bastion" {
  count = 1

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "${var.cidr-start}.${count.index}.0/24"
  vpc_id            = aws_vpc.bastion.id

  tags = {
    Name = "bastion-${var.environment-name}-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "bastion" {
  vpc_id = aws_vpc.bastion.id

  tags = {
    Name = "bastion-${var.environment-name}-ig"
  }
}

resource "aws_route_table" "bastion" {
  vpc_id = aws_vpc.bastion.id

  tags = {
    Name = "bastion-${var.environment-name}-rt"
  }
}

resource "aws_route" "bastion-ipv4-out" {
  route_table_id         = aws_route_table.bastion.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.bastion.id
}

resource "aws_route_table_association" "bastion" {
  count = 1

  subnet_id      = aws_subnet.bastion[count.index].id
  route_table_id = aws_route_table.bastion.id
}

variable "everyone-cidr" {
  default     = "0.0.0.0/0"
  description = "Everyone"
}

module "ssh-bastion-service" {
  source = "joshuamkite/ssh-bastion-service/aws"
  # source                        = "../../"
  aws_region                    = var.aws-region
  aws_environment              = var.environment-name
  vpc                           = aws_vpc.bastion.id
  asg_subnets                   = flatten([aws_subnet.bastion.*.id])
  lb_subnets                    = flatten([aws_subnet.bastion.*.id])
  bastion_cidr_blocks_whitelist = [var.everyone-cidr]
  host_public_ip                = true
  depends_on = [
    aws_vpc.bastion,
    aws_subnet.bastion,
    aws_internet_gateway.bastion,
  ]
}
