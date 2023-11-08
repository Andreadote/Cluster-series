
output "efs_id" {
  value = aws_efs_file_system.stw_node_efs.id
}

output "cluster_id" {
  value = data.aws_eks_cluster.this.cluster_id
}
