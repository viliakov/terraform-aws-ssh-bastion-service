##################
# security group for bastion_service
##################

resource "aws_security_group" "bastion_service" {
  name                   = local.sg_name
  description            = "Bastion service SSH SecurityGroup"
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  tags                   = merge({Name = local.sg_name}, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

##################
# security group rules for bastion_service
##################

# SSH access in from whitelist IP ranges

resource "aws_security_group_rule" "service_ssh_in" {
  count             = local.bastion_cidr_blocks_whitelist_yes //? 1 : 0
  type              = "ingress"
  from_port         = var.bastion_ssh_port
  to_port           = var.bastion_ssh_port
  protocol          = "tcp"
  cidr_blocks       = var.bastion_cidr_blocks_whitelist
  security_group_id = aws_security_group.bastion_service.id
  description       = "bastion service access"
}

# SSH access in from whitelist IP ranges for Bastion Host - conditional

resource "aws_security_group_rule" "host_ssh_in_cond" {
  count             = local.hostport_whitelisted ? 1 : 0
  type              = "ingress"
  from_port         = var.host_ssh_port
  to_port           = var.host_ssh_port
  protocol          = "tcp"
  cidr_blocks       = var.host_cidr_blocks_whitelist
  security_group_id = aws_security_group.bastion_service.id
  description       = "bastion HOST access"
}

# Permissive egress policy because we want users to be able to install their own packages

resource "aws_security_group_rule" "bastion_host_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  security_group_id = aws_security_group.bastion_service.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "bastion service and host egress"
}

# access from lb cidr ranges for healthchecks

data "aws_subnet" "lb_subnets" {
  count = length(var.lb_subnets)
  id    = var.lb_subnets[count.index]
}

resource "aws_security_group_rule" "lb_healthcheck_in" {
  security_group_id = aws_security_group.bastion_service.id
  cidr_blocks       = data.aws_subnet.lb_subnets.*.cidr_block
  from_port         = var.lb_healthcheck_port
  to_port           = var.lb_healthcheck_port
  protocol          = "tcp"
  type              = "ingress"
  description       = "access from load balancer CIDR ranges for healthchecks"
}

