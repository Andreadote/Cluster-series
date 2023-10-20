
output "private" {
  value = aws_subnet.private.*.id
}

output "public" {
  value = aws_subnet.public.*.id
}


#role for the demo
output "node_role" {
  value = aws_iam_role.nodes.arn
}


#role for the cluster
output "demo_role" {
  value = aws_iam_role.demo.arn
}

