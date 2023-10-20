data "aws_iam_policy_document" "developer" {
  statement {
    sid    = "AllowDeveloper"
    effect = "Allow"
    actions = [
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:DescribeCluster",
      "eks:ListClusters",
      "eks:AccessKubernetesApi",
      "ssm:GetParameter",
      "eks:ListUpdates",
      "eks:ListFargateProfiles"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "masters" {
  statement {
    sid       = "AllowAdmin"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
  statement {
    sid    = "AllowPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "masters_assume_role" {
  statement {
    sid    = "AllowAccountAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "AWS"
      # When you are addind a group to a the the principle you use an account instead of the arn
      #identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/manager"] #( this is for a user)
      identifiers = [data.aws_caller_identity.current.account_id]
      #identifiers = ["data.aws_caller_identity.current.account_id]
    }
  }
}

# am passing this just as an policy not an assume_role policy big difference..  ( am passinfg my role as a resources)
data "aws_iam_policy_document" "masters_role" {
  statement {
    sid    = "AllowMastersAssumeRole"
    effect = "Allow"
    actions = ["sts:AssumeRole"]
      # When you are addind a group to a the the principle you use an account instead of the arn
      resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/masters-eks-Role"] #( this is for a user)
      #identifiers = [data.aws_caller_identity.current.account_id]
    }
  }

data "aws_caller_identity" "current" {}



