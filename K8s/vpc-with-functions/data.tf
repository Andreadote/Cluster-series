#Assume role policy for node
data "aws_iam_policy_document" "nodes" {
  statement {
    sid     = "AllowEKSAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#Assume role policy for cluster
data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    sid     = "AllowEksAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}
