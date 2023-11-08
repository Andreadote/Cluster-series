# EFS file system
locals {
  efs_sg   = data.terraform_remote_state.network.outputs.efs_sg
}

#efs file system
resource "aws_efs_file_system" "stw_node_efs" {
  creation_token = "efs-for-stw-node"

  tags = {
    Name = "eks-file-system"
  }
}

#efs mount targets
resource "aws_efs_mount_target" "stw_node_efs_mt_0" {
  file_system_id  = aws_efs_file_system.stw_node_efs.id
  subnet_id       = data.terraform_remote_state.network.outputs.private[0]
  security_groups = [local.efs_sg]
}

resource "aws_efs_mount_target" "stw_node_efs_mt_1" {
  file_system_id  = aws_efs_file_system.stw_node_efs.id
  subnet_id       = data.terraform_remote_state.network.outputs.private[1]
  security_groups = [local.efs_sg]
}

