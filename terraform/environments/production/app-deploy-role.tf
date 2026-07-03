data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "app_deploy_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [trimspace(var.github_oidc_provider_arn)]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${trimspace(var.github_deploy_repository)}:environment:${trimspace(var.github_deploy_environment)}",
      ]
    }
  }
}

resource "aws_iam_role" "app_deploy" {
  name                 = var.app_deploy_role_name
  assume_role_policy   = data.aws_iam_policy_document.app_deploy_assume_role.json
  max_session_duration = 3600

  tags = merge(local.common_tags, {
    Name    = var.app_deploy_role_name
    Purpose = "application-deployment"
  })
}

data "aws_iam_policy_document" "app_deploy" {
  statement {
    sid     = "UseRunShellScriptDocument"
    actions = ["ssm:SendCommand"]
    resources = [
      "arn:${data.aws_partition.current.partition}:ssm:${var.region}::document/AWS-RunShellScript",
    ]
  }

  statement {
    sid       = "SendCommandToProductionInstance"
    actions   = ["ssm:SendCommand"]
    resources = [module.compute.instance_arn]
  }

  statement {
    sid = "ReadCommandStatus"
    actions = [
      "ssm:GetCommandInvocation",
      "ssm:ListCommandInvocations",
      "ssm:ListCommands",
    ]
    resources = ["*"]
  }

  statement {
    sid = "DiscoverProductionInstance"
    actions = [
      "ec2:DescribeInstances",
      "ssm:DescribeInstanceInformation",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "app_deploy" {
  name   = "deploy-to-production-ec2"
  role   = aws_iam_role.app_deploy.id
  policy = data.aws_iam_policy_document.app_deploy.json
}
