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

    # Required
    # security_group_id = aws_eks_cluster.demo.vpc_config[0.cluster_security_group.id
    security_group_id  = aws_security_group.cluster.id
    protocol           = each.value.protocol
    from_port          = each.value.from_port
    to_port            = each.value.to_port
    type               = each.value.type
    # cidr_blocks = each.value.cidr_blocks

    # optional
    description  = try(each.value.description, null)
    cirdr_blocks = try(each.value.cirdr_blocks, null)
    self         = try(each.value.self, null)



 resource "aws_security_group" "allow_nfs" {
    name   = "allow nfs for efs"
    description = "Allow NFS inbound traffic"
    vpc_id      = local.vpc_id

        ingress = {
            description "NFS from VPC"
            from_port   = 2049
            to_port     = 2049
            protocol    = "tcp"
            cidr-blocks = [ local.vpc_cidr]
        }
        ingress = {
            from_port   = 0
            to_port     = 0
            protocol    = " 1 "
            self        = true
    
    }
        ingress = {
            from_port             = 0
            to_port               = 0
            protocol              = " 1 "
            security_groups       = [aws_security_group.cluster.id]
    
    }
        egress = {
            description "NFS from VPC"
            from_port             = 0
            to_port               = 0
            protocol              = " 1 "
            security_groups       = ["0.0.0.0./0"]
            ipv6_cidr_blocks      = ["::/0"]
    
    }
 }









