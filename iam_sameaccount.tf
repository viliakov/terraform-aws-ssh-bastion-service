
data "aws_iam_policy_document" "check_ssh_authorized_keys" {
  count = local.assume_role_no

  statement {
    effect = "Allow"

    actions = [
      "iam:ListUsers",
      "iam:GetGroup",
      "iam:GetSSHPublicKey",
      "iam:ListSSHPublicKeys",
      "iam:GetUser",
      "iam:ListGroups",
      "ec2:DescribeTags",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "check_ssh_authorized_keys" {
  count  = local.assume_role_no
  name = local.service_name
  policy = data.aws_iam_policy_document.check_ssh_authorized_keys[0].json
}

resource "aws_iam_role_policy_attachment" "check_ssh_authorized_keys" {
  count      = local.assume_role_no
  role       = aws_iam_role.bastion_service_role.name
  policy_arn = aws_iam_policy.check_ssh_authorized_keys[0].arn
}
