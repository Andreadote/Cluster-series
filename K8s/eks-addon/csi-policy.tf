# efs IAM policy
resource "aws_iam_policy" "efs_csi" {
  count  = var.create_role && var.attach_efs_csi_policy ? 1 : 0
  name   = "efs-csi-policy"
  policy = data.aws_iam_policy_document.efs_csi[0].json
}

# IAM policy attachment
resource "aws_iam_role_policy_attachment" "efs_csi" {
  count      = var.create_role && var.attach_efs_csi_policy ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.efs_csi[0].arn
}

# efs IAM role
resource "aws_iam_role" "this" {
  count              = var.create_role ? 1 : 0
  name               = "efs-csi"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_assume_role_policy[0].json
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

