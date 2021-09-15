#######################################################
# LB section
#######################################################

resource "aws_lb" "bastion-service" {
  name                             = md5(format("${var.service_name}-%s", var.vpc_id))
  load_balancer_type               = "network"
  internal                         = var.lb_is_internal
  subnets                          = var.lb_subnets
  enable_cross_zone_load_balancing = false
  tags                             = var.tags
}

######################################################
# Listener- Port 22 -service only
######################################################

resource "aws_lb_listener" "bastion-service" {
  load_balancer_arn = aws_lb.bastion-service.arn
  protocol          = "TCP"
  port              = var.bastion_ssh_port

  default_action {
    target_group_arn = aws_lb_target_group.bastion-service.arn
    type             = "forward"
  }
}

######################################################
# Listener- Port 2222 - service and host - conditional
######################################################

resource "aws_lb_listener" "bastion-host" {
  count             = local.hostport_whitelisted ? 1 : 0
  load_balancer_arn = aws_lb.bastion-service.arn
  protocol          = "TCP"
  port              = var.host_ssh_port

  default_action {
    target_group_arn = aws_lb_target_group.bastion-host[0].arn
    type             = "forward"
  }
}

######################################################
# Target group service
#######################################################
resource "aws_lb_target_group" "bastion-service" {
  name     = md5(format("${var.service_name}-%s", var.vpc_id))
  protocol = "TCP"
  port     = var.bastion_ssh_port
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    interval            = var.lb_interval
    protocol            = "TCP"
    port                = var.lb_healthcheck_port
  }

  tags = var.tags
}

######################################################
# Target group 	host - conditional
#######################################################
resource "aws_lb_target_group" "bastion-host" {
  count    = local.hostport_whitelisted ? 1 : 0
  name     = "bastion-host"
  protocol = "TCP"
  port     = var.host_ssh_port
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    interval            = var.lb_interval
    protocol            = "TCP"
    port                = var.lb_healthcheck_port
  }

  tags = var.tags
}

