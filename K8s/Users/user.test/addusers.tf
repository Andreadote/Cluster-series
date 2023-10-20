
data "aws_iam_users" "users" {}

output "users" {
  value = "data.aws_iam_users.users.arns"
}
output "users1" {
  value = "data.aws_iam_users.users.ids"
}
output "users2" {
  value = "data.aws_iam_users.users.names"
}

resource "aws_iam_group_membership" "dev_team" {
  name  = "group-membership"
  users = data.aws_iam_users.users.names
  group = "Developer"
}