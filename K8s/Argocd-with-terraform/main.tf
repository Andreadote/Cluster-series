# Namespace
resource "kubectl_manifest" "namespace" {
  for_each           = data.kubectl_file_documents.namespace.manifests
  yaml_body          = each.value
  override_namespace = "argocd"
}

# Argo installation
resource "kubectl_manifest" "argocd" {
  depends_on = [
    kubectl_manifest.namespace,
  ]
  for_each           = data.kubectl_file_documents.argocd.manifests
  yaml_body          = each.value
  override_namespace = "argocd"
}

# Argo SVC
resource "kubectl_manifest" "svc" {
  depends_on = [
    kubectl_manifest.argocd,
  ]
  for_each           = data.kubectl_file_documents.svc.manifests
  yaml_body          = each.value
  override_namespace = "argocd"
}

# Repo secrets
resource "kubectl_manifest" "app_repos" {
  depends_on = [
    kubectl_manifest.svc
  ]
  for_each           = data.kubectl_file_documents.repos-secret.manifests
  yaml_body          = each.value
  override_namespace = "argocd"
}

resource "kubectl_manifest" "helm_repos" {
  depends_on = [
    kubectl_manifest.svc
  ]
  for_each           = data.kubectl_file_documents.helm-repos-secret.manifests
  yaml_body          = each.value
  override_namespace = "argocd"
}

# Repos
resource "kubectl_manifest" "app_set" {
  depends_on = [
    kubectl_manifest.app_repos
  ]
  for_each           = data.kubectl_file_documents.appset.manifests
  yaml_body          = each.value
  override_namespace = "argocd"
}

resource "kubectl_manifest" "helm_set" {
  depends_on = [
    kubectl_manifest.helm_repos
  ]
  for_each           = data.kubectl_file_documents.app-set.manifests
  yaml_body          = each.value
  override_namespace = "argocd"
}