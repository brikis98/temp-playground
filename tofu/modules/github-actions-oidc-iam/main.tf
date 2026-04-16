resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 1 : 0

  url             = var.github_oidc_provider_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.github_oidc_thumbprints
}

locals {
  github_oidc_provider_arn = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : var.existing_github_oidc_provider_arn

  main_branch_sub  = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/main"
  any_branch_sub   = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/*"
  pull_request_sub = "repo:${var.github_owner}/${var.github_repo}:pull_request"

  tofu_state_bucket_arn    = "arn:aws:s3:::${var.tofu_state_bucket_name}"
  tofu_state_object_arn    = "arn:aws:s3:::${var.tofu_state_bucket_name}/${var.tofu_state_key}"
  tofu_lockfile_key        = "${var.tofu_state_key}.tflock"
  tofu_lockfile_object_arn = "arn:aws:s3:::${var.tofu_state_bucket_name}/${local.tofu_lockfile_key}"
}

data "aws_iam_policy_document" "docker_push_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.main_branch_sub]
    }
  }
}

resource "aws_iam_role" "docker_push" {
  name               = var.docker_push_role_name
  assume_role_policy = data.aws_iam_policy_document.docker_push_trust.json
}

data "aws_iam_policy_document" "docker_push_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = var.ecr_repository_arns
  }
}

resource "aws_iam_role_policy" "docker_push" {
  name   = "docker-push-ecr"
  role   = aws_iam_role.docker_push.id
  policy = data.aws_iam_policy_document.docker_push_permissions.json
}

data "aws_iam_policy_document" "tofu_plan_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        local.any_branch_sub,
        local.pull_request_sub,
      ]
    }
  }
}

resource "aws_iam_role" "tofu_plan" {
  name               = var.tofu_plan_role_name
  assume_role_policy = data.aws_iam_policy_document.tofu_plan_trust.json
}

data "aws_iam_policy_document" "tofu_plan_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "ecr:Describe*",
      "ecr:Get*",
      "ecr:List*",
      "eks:Describe*",
      "eks:List*",
      "iam:Get*",
      "iam:List*",
      "sso:Describe*",
      "sso:List*",
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [local.tofu_state_bucket_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      local.tofu_state_object_arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      local.tofu_lockfile_object_arn,
    ]
  }
}

resource "aws_iam_role_policy" "tofu_plan" {
  name   = "tofu-plan-read-only"
  role   = aws_iam_role.tofu_plan.id
  policy = data.aws_iam_policy_document.tofu_plan_permissions.json
}

data "aws_iam_policy_document" "tofu_apply_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.main_branch_sub]
    }
  }
}

resource "aws_iam_role" "tofu_apply" {
  name               = var.tofu_apply_role_name
  assume_role_policy = data.aws_iam_policy_document.tofu_apply_trust.json
}

data "aws_iam_policy_document" "tofu_apply_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:Describe*",
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:Describe*",
      "ecr:Get*",
      "ecr:List*",
      "ecr:TagResource",
      "ecr:UntagResource",
      "eks:Associate*",
      "eks:Create*",
      "eks:Delete*",
      "eks:Describe*",
      "eks:Disassociate*",
      "eks:List*",
      "eks:TagResource",
      "eks:UntagResource",
      "eks:Update*",
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:CreateServiceLinkedRole",
      "iam:DeleteRole",
      "iam:DetachRolePolicy",
      "iam:Get*",
      "iam:List*",
      "iam:PassRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "sso:Describe*",
      "sso:List*",
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [local.tofu_state_bucket_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      local.tofu_state_object_arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      local.tofu_lockfile_object_arn,
    ]
  }
}

resource "aws_iam_role_policy" "tofu_apply" {
  name   = "tofu-apply-read-write"
  role   = aws_iam_role.tofu_apply.id
  policy = data.aws_iam_policy_document.tofu_apply_permissions.json
}
