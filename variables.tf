##############################
# Bastion service variables
##############################
variable "bastion_allowed_iam_group" {
  type        = string
  description = "Name IAM group, members of this group will be able to ssh into bastion instances if they have provided ssh key in their profile"
  default     = ""
}

variable "bastion_assume_role_arn" {
  description = "arn for role to assume in separate identity account if used"
  default     = ""
}

variable "bastion_cidr_blocks_whitelist" {
  description = "range(s) of incoming IP addresses to whitelist for the Bastion SERVICE"
  type        = list(string)
  default     = []
}

variable "bastion_container_image" {
  description = "The Docker image booted on an SSH connection"
  type = string
  default = "ubuntu:20.04"
}

variable "bastion_host_name" {
  type        = string
  default     = ""
  description = "The hostname to give to the bastion instance"
}

variable "bastion_ssh_port" {
  description = "The port that the bastion SSH daemon should be exposed on"
  default = 22
  type = number
}

variable "bastion_vpc_name" {
  description = "define the last part of the hostname, by default this is the vpc ID with magic default value of 'vpc_id' but you can pass a custom string, or an empty value to omit this"
  default     = "vpc_id"
}

##############################
# Host instance variables
##############################
variable "host_ami_id" {
  description = "AMI ID to run the Bastion HOST instance. If left empty the latest Ubuntu will be used."
  default     = ""
}

variable "host_cidr_blocks_whitelist" {
  description = "range(s) of incoming IP addresses to whitelist for the Bastion HOST instance"
  type        = list(string)
  default     = []
}

variable "host_instance_type" {
  description = "The virtual hardware to be used for the bastion service host"
  default     = "t2.micro"
}

variable "host_public_ip" {
  type        = bool
  default     = false
  description = "Associate a public IP with the host instance when launching"
}

variable "host_ssh_port" {
  description = "The port that the host SSH daemon should be exposed on"
  default = 2222
  type = number
}

variable "host_ssh_public_key" {
  description = "The public key that is authorized to SSH into the bastion host"
  default = ""
  type = string
}

variable "host_ssh_username" {
  description = "The default username used to SSH into the bastion host"
  default = "admin"
  type = string
}

##########################
# AWS variables
##########################
variable "name" {
  description = "Name of this Terraform deployment, used as a prefix for various resources"
  type = string
}

variable "aws_environment" {
  description = "the name of the AWS environment that we are deploying to (i.e. prod, staging, preprod, etc)"
  type = string
}

variable "vpc_id" {
  description = "ID for Virtual Private Cloud to apply security policy and deploy stack to"
  type = string
}

variable "tags" {
  type        = map(string)
  description = "AWS tags that should be associated with created resources"
  default     = {}
}

variable "security_groups_additional" {
  description = "additional security group IDs to attach to host instance"
  type        = list(string)
  default     = []
}

variable "dns_domain" {
  description = "The domain used for Route53 records"
  type = string
  default = ""
}

##########################
# Route 53 variables
##########################
variable "route53_fqdn" {
  description = "If creating a public DNS entry with this module then you may override the default constructed DNS entry by supplying a fully qualified domain name here which will be used verbatim"
  default     = ""
}

variable "route53_zone_id" {
  description = "Route53 zoneId"
  default     = ""
}

##############################
# LoadBalancer variables
##############################
variable "lb_healthcheck_port" {
  description = "TCP port to conduct lb target group healthchecks. Acceptable values are 22 or 2222"
  default     = "2222"
}

variable "lb_healthy_threshold" {
  type        = string
  description = "Healthy threshold for lb target group"
  default     = "2"
}

variable "lb_interval" {
  type        = string
  description = "interval for lb target group health check"
  default     = "30"
}

variable "lb_is_internal" {
  type        = string
  description = "whether the lb will be internal"
  default     = false
}

variable "lb_subnets" {
  type        = list(string)
  description = "list of subnets for load balancer - availability zones must match asg_subnets"
  default     = []
}

variable "lb_unhealthy_threshold" {
  type        = string
  description = "Unhealthy threshold for lb target group"
  default     = "2"
}

##############################
# AutoScalingGroup variables
##############################
variable "asg_desired" {
  type        = string
  description = "Desired numbers of bastion-service hosts in ASG"
  default     = "1"
}

variable "asg_max" {
  type        = string
  description = "Max numbers of bastion-service hosts in ASG"
  default     = "2"
}

variable "asg_min" {
  type        = string
  description = "Min numbers of bastion-service hosts in ASG"
  default     = "1"
}

variable "asg_subnets" {
  type        = list(string)
  description = "list of subnets for autoscaling group - availability zones must match lb_subnets"
  default     = []
}

##########################
# Extra User Data variables
##########################
variable "extra_user_data_content" {
  default     = ""
  description = "Extra user-data to add to the default built-in"
}

variable "extra_user_data_content_type" {
  default     = "text/x-shellscript"
  description = "What format is content in - eg 'text/cloud-config' or 'text/x-shellscript'"
}

variable "extra_user_data_merge_type" {
  # default     = "list(append)+dict(recurse_array)+str()"
  default     = "str(append)"
  description = "Control how cloud-init merges user-data sections"
}

variable "custom_ssh_populate" {
  description = "If set to true, will disable the default ssh_populate script used on container launch from userdata"
  type        = bool
  default     = false
}

variable "custom_authorized_keys_command" {
  description = "If set to true, will disable the default Go binary iam-authorized-keys"
  type        = bool
  default     = false
}

variable "custom_docker_setup" {
  description = "If set to true, will disable the default docker installation and container build from userdata"
  type        = bool
  default     = false
}

variable "custom_systemd" {
  description = "If set to true, will disable the default systemd and hostname change from userdata"
  type        = bool
  default     = false
}
