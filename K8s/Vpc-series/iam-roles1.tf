locals {
  eks_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ]

  node_policies = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

}
#Role and policies for node groups
resource "aws_iam_role" "node" {
  name = "eks-node-group-nodes"
  assume_role_policy = jsonencode({
    "version" : "2012-10-17",
    "statement" : [{
        "Effect" : "Allow",
        "Action" : "sts:assumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      }]
  })
}


# 1. Create IAM roles for node groups
#resource "aws_iam_role" "nodes" {
  #name               = "eks-node-group-nodes"
  #assume_role_policy = data.aws_iam_policy_document.nodes.json
#}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  for_each   = toset(local.node_policies)
  policy_arn = each.value
  role       = aws_iam_role.nodes.name
}

# 2. Create IAM role for EKS cluster
#resource "aws_iam_role" "demo" {
  #name               = "eks-cluster-demo"
  #assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
#}

#Role and policies for eks cluster
resource "aws_iam_role" "demo" {
  name = "eks-cluster-demo"
  assume_role_policy = jsonencode({
    "version" : "2012-10-17",
    "statement" : [{
        "Effect" : "Allow",
        "Action" : "sts:assumeRole",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        }
      }]
  })
}




resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  for_each   = toset(local.eks_policies)
  policy_arn = each.value
  role       = aws_iam_role.demo.name
}
