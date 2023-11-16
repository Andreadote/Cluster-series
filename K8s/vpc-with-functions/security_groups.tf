# Cluster Security Group
# Defaults follow https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html

locals {
  #cluster_name = aws_cluster.demo.name 
  vpc_id = aws_vpc.main.id
  vpc_cidr = var.vpc_cidr
  cluster_security_group_rules = {
    ingress_nodes_all = {
        description = "Node groups to cluster API"
        protocol = "-1"
        from_port = 1
        to_port = 65535
        type    = "ingress"
        cidr_blocks = ["0.0.0.0/0"]
        # source_node_security_group = true
    }
    egress_nodes_all = {
        description = "cluster API to Node groups "
        protocol = "-1"
        from_port = 1
        to_port = 65535
        type    = "egress"
        self    = true
        #cidr_blocks = ["0.0.0.0/0"]
        # source_node_security_group = true
  }
}
tags = {
    "kubernetes.io/cluster/demo"      = "owned"
    Name                              = " eks-cluster-sg-demo"
}
}

resource "aws_security_group" "cluster" {
  name  = "eks-cluster-sg-demo"
  description = "EKS cluster security group"
  vpc_id =  local.vpc_id

  #tags = local.tags

}
 resource "aws_security_group_rule" "cluster" {
   for_each = { for k, v in local.local.cluster_security_group_rules : k => v }
 }










