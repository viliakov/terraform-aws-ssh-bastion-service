#role in child account

data "aws_iam_policy_document" "bastion_service_assume_role" {
  count = local.assume_role_yes

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      var.bastion_assume_role_arn,
    ]
  }
}

resource "aws_iam_policy" "bastion_service_assume_role" {
  count = local.assume_role_yes
  name = "${local.role_name}-assume"
  policy = data.aws_iam_policy_document.bastion_service_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "bastion_service_assume_role" {
  count      = local.assume_role_yes
  role       = aws_iam_role.bastion_service_role.name
  policy_arn = aws_iam_policy.bastion_service_assume_role[0].arn
}

