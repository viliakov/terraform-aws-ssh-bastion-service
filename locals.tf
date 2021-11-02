##########################
#Create local for bastion hostname
##########################

locals {
  bastion_vpc_name = var.bastion_vpc_name == "vpc_id" ? var.vpc_id : var.bastion_vpc_name
  bastion_host_name = var.bastion_host_name == "" ? join(
    "-",
    compact(
      [
        var.aws_environment,
        data.aws_region.current.name,
        local.bastion_vpc_name,
      ],
    ),
  ) : var.bastion_host_name
}

##########################
# Logic for security group and listeners
##########################
locals {
  hostport_whitelisted = join(",", var.host_cidr_blocks_whitelist) != ""
  hostport_healthcheck = var.lb_healthcheck_port == "2222"
}

##########################
# Logic tests for  assume role vs same account
##########################
locals {
  assume_role_yes = var.bastion_assume_role_arn != "" ? 1 : 0
  assume_role_no  = var.bastion_assume_role_arn == "" ? 1 : 0
}


##########################
# Logic for using module default or custom ami
##########################

locals {
  bastion_ami_id                = var.host_ami_id == "" ? data.aws_ami.ubuntu.id : var.host_ami_id
  bastion_ami_root_block_device = data.aws_ami.ubuntu.root_device_name
}

##########################
# Logic for using bastion_cidr_blocks_whitelist ONLY if provided
##########################

locals {
  bastion_cidr_blocks_whitelist_yes = join(",", var.bastion_cidr_blocks_whitelist) != "" ? 1 : 0
}

##########################
# Construct route53 name for historical behaviour where used
##########################

locals {
  route53_name_components = "bastion.${var.name}.${var.aws_environment}.${var.dns_domain}"
}

locals {
  instance_name  = "bastion.${var.name}.${var.aws_environment}.${var.dns_domain}"
  role_name      = "bastion.${var.name}.${var.aws_environment}.${var.dns_domain}"
  lb_name_prefix = substr("bastion-${var.name}-${var.aws_environment}", 0, 25)
  sg_name        = "bastion-${var.name}-${var.aws_environment}-${var.dns_domain}"
}

locals {
  # The ASG tags are propagated onto the EC2 instances
  ec2_tags = merge(var.asg_tags, { "Name" = local.instance_name })
}
