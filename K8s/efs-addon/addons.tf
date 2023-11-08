# Addons
resource "aws_eks_addon" "addons" {
  for_each                    = { for addon in var.addons : addon.name => addon }
  cluster_name                = data.aws_eks_cluster.this.name
  addon_name                  = each.value.name
  addon_version               = each.value.version
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.this[0].arn
}