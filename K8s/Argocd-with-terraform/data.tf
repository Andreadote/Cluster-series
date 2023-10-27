# Cluster data
data "aws_eks_cluster" "cluster" {
  name = "demo"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "demo"
}

# Namespace
data "kubectl_file_documents" "namespace" {
  content = file("${path.module}/manifests/namespace.yaml")
}

# Argo CRD installation
data "kubectl_file_documents" "argocd" {
  content = file("${path.module}/manifests/install.yaml")
}

# Argo svc
data "kubectl_file_documents" "svc" {
  content = file("${path.module}/manifests/service.yaml")
}

# Repos secrets
data "kubectl_file_documents" "repos-secret" {
  content = file("${path.module}/manifests/secret.yaml")
}

data "kubectl_file_documents" "helm-repos-secret" {
  content = file("${path.module}/manifests/secret-helm.yaml")
}

# Repos
data "kubectl_file_documents" "appset" {
  content = file("${path.module}/manifests/app-set.yaml")
}

data "kubectl_file_documents" "app-set" {
  content = file("${path.module}/manifests/app-set-helm.yaml")
}