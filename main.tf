############################
#Launch configuration for service host
############################

resource "aws_launch_template" "bastion-service-host" {
  name                   = local.instance_name
  image_id               = local.bastion_ami_id
  instance_type          = var.host_instance_type
  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.bastion_service_profile.arn
  }

  network_interfaces {
    associate_public_ip_address = var.host_public_ip
    security_groups = concat(
      [aws_security_group.bastion_service.id],
      var.security_groups_additional
    )
  }

  user_data = data.template_cloudinit_config.config.rendered

  block_device_mappings {
    device_name = local.bastion_ami_root_block_device
    ebs {
      volume_size = 16
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.ec2_tags
  }
}

#######################################################
# ASG section
#######################################################

resource "aws_autoscaling_group" "bastion-service" {
  name             = "${local.instance_name}-asg"
  max_size         = var.asg_max
  min_size         = var.asg_min
  desired_capacity = var.asg_desired
  launch_template {
    id      = aws_launch_template.bastion-service-host.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.asg_subnets
  target_group_arns = concat(
    [aws_lb_target_group.bastion-service.arn],
    aws_lb_target_group.bastion-host.*.arn
  )

  # The ASG tags need not be propagated to the instances, as those receive their tags through the launch template
  # This prevents duplicate tags overwriting eachother
  dynamic "tag" {
    for_each = var.asg_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }
}

####################################################
# DNS Section
###################################################

resource "aws_route53_record" "bastion_service" {
  count   = var.route53_zone_id != "" ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.route53_fqdn == "" ? local.route53_name_components : var.route53_fqdn
  type    = "A"

  alias {
    name                   = aws_lb.bastion-service.dns_name
    zone_id                = aws_lb.bastion-service.zone_id
    evaluate_target_health = true
  }
}

####################################################
# sample policy for parent account
###################################################

data "template_file" "sample_policies_for_parent_account" {
  count    = local.assume_role_yes
  template = file("${path.module}/sts_assumerole_example/policy_example.tpl")

  vars = {
    aws_account_arn           = data.aws_caller_identity.current.arn
    bastion_allowed_iam_group = var.bastion_allowed_iam_group
    bastion_assume_role_arn   = var.bastion_assume_role_arn
  }
}
