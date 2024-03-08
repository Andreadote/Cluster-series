variable "create_role" {
  type    = bool
  default = true
}

variable "attach_efs_csi_policy" {
  type    = bool
  default = true
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}