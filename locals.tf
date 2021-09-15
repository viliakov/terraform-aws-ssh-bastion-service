##########################
#Create local for bastion hostname
##########################

locals {
  bastion_vpc_name = var.bastion_vpc_name == "vpc_id" ? var.vpc_id : var.bastion_vpc_name
  bastion_host_name = var.bastion_host_name == "" ? join(
    "-",
    compact(
      [
        var.environment_name,
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
  bastion_ami_id = var.host_ami_id == "" ? data.aws_ami.ubuntu.id : var.host_ami_id
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
  route53_name_components = "${local.bastion_host_name}-${var.service_name}.${var.dns_domain}"
}

locals {
  service_name = var.service_name == "bastion-service" ? format(
    "%s-%s-%s_bastion",
    var.environment_name,
    data.aws_region.current.name,
    var.vpc_id,
  ) : var.service_name
}
