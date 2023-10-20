data "aws_eks_cluster" "my-cluster" {
  name = "demo"
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.my-cluster.identity[0].oidc[0].issuer
}

#IAM POLICY FOR OIDC PROVIDER

data "aws_iam_policy_document" "test_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-test"]
    }


    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}