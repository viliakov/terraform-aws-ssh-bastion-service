# aws iam role for host

resource "aws_iam_role" "bastion_service_role" {
  name = local.service_name
  assume_role_policy = data.aws_iam_policy_document.bastion_service_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "bastion_service_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

#########################
#Instance profile to assume role
#########################

resource "aws_iam_instance_profile" "bastion_service_profile" {
  name = local.service_name
  role = aws_iam_role.bastion_service_role.name
}

