output "service_dns_entry" {
  description = "dns-registered url for service and host"
  value       = join("", aws_route53_record.bastion_service.*.name)
}

output "policy_example_for_parent_account_empty_if_not_used" {
  description = "You must apply an IAM policy with trust relationship identical or compatible with this in your other AWS account for IAM lookups to function there with STS:AssumeRole and allow users to login"
  value       = local.sample_policies_for_parent_account_template
}

output "bastion_sg_id" {
  description = "Security Group id of the bastion host"
  value       = aws_security_group.bastion_service.id
}

output "lb_dns_name" {
  description = "aws load balancer dns"
  value       = aws_lb.bastion-service.dns_name
}

output "lb_zone_id" {
  value = aws_lb.bastion-service.zone_id
}

output "bastion_service_role_name" {
  description = "role created for service host asg - if created without assume role"
  value       = aws_iam_role.bastion_service_role.*.name
}

output "lb_arn" {
  description = "aws load balancer arn"
  value       = aws_lb.bastion-service.arn
}

output "target_group_arn" {
  description = "aws load balancer target group arn"
  value       = aws_lb_target_group.bastion-service.arn
}

output "host_ssh_public_key" {
  description = "SSH public key for the bastion host instance"
  value       = var.host_ssh_public_key
}

output "host_ssh_username" {
  description = "SSH username for the bastion host instance"
  value       = var.host_ssh_username
}
