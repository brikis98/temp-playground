resource "aws_grafana_workspace" "this" {
  name                      = var.name
  description               = var.description
  account_access_type       = var.account_access_type
  authentication_providers  = var.authentication_providers
  role_arn                  = aws_iam_role.workspace.arn
  data_sources              = var.data_sources
  grafana_version           = var.grafana_version
  notification_destinations = var.notification_destinations

  # Currently, this is the only option when using APIs or OpenTofu to provision Grafana
  permission_type = "CUSTOMER_MANAGED"

  depends_on = [aws_iam_role_policy_attachment.cloudwatch_access]
}

data "aws_iam_policy_document" "workspace_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["grafana.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "workspace" {
  name               = "${var.name}-workspace-role"
  assume_role_policy = data.aws_iam_policy_document.workspace_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_access" {
  count = contains(var.data_sources, "CLOUDWATCH") ? 1 : 0

  role       = aws_iam_role.workspace.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonGrafanaCloudWatchAccess"
}

resource "aws_grafana_role_association" "admin" {
  count = length(var.admin_user_ids) > 0 || length(var.admin_group_ids) > 0 ? 1 : 0

  workspace_id = aws_grafana_workspace.this.id
  role         = "ADMIN"
  user_ids     = var.admin_user_ids
  group_ids    = var.admin_group_ids
}

resource "aws_grafana_role_association" "editor" {
  count = length(var.editor_user_ids) > 0 || length(var.editor_group_ids) > 0 ? 1 : 0

  workspace_id = aws_grafana_workspace.this.id
  role         = "EDITOR"
  user_ids     = var.editor_user_ids
  group_ids    = var.editor_group_ids
}

resource "aws_grafana_role_association" "viewer" {
  count = length(var.viewer_user_ids) > 0 || length(var.viewer_group_ids) > 0 ? 1 : 0

  workspace_id = aws_grafana_workspace.this.id
  role         = "VIEWER"
  user_ids     = var.viewer_user_ids
  group_ids    = var.viewer_group_ids
}
