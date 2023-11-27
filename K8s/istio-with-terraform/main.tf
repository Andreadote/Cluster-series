
locals {
  istio_charts_url = "https://istio-release.storage.googleapis.com/charts"
}

#Istio namespace
resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

# Istio base release
resource "helm_release" "istio-base" {
  repository = local.istio_charts_url
  chart      = "base"
  name       = "istio-base"
  namespace  = kubernetes_namespace.istio_system.id
  cleanup_on_fail = true
  force_update    = false

  depends_on = [kubernetes_namespace.istio_system]
}

# Istiod release
resource "helm_release" "istiod" {
  repository      = local.istio_charts_url
  chart           = "istiod"
  name            = "istiod"
  namespace       = kubernetes_namespace.istio_system.id
  cleanup_on_fail = true
  force_update    = false

  depends_on = [helm_release.istio-base]
}

# Default namespace label istio-system
resource "kubernetes_labels" "example" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "default"
  }
  labels = {
    istio-injection = "enabled"
  }
}

#Kiali dashboard
resource "kubectl_manifest" "kiali" {
  for_each           = data.kubectl_file_documents.kiali.manifests
  yaml_body          = each.value
  override_namespace = "istio-system"

  #depends_on = [helm_release.istio-ingress]
}

data "kubectl_file_documents" "kiali" {
  content = file("${path.module}/manifests/kiali.yaml")
}

# Book info application
resource "kubectl_manifest" "book-info" {
  for_each           = data.kubectl_file_documents.book-info.manifests
  yaml_body          = each.value
  override_namespace = "default"

  depends_on = [kubectl_manifest.kiali]
}

data "kubectl_file_documents" "book-info" {
  content = file("${path.module}/manifests/bookinfo.yaml")
}

# Prometheus deployment
resource "kubectl_manifest" "prometheus" {
  for_each           = data.kubectl_file_documents.prometheus.manifests
  yaml_body          = each.value
  override_namespace = "istio-system"

  depends_on = [kubectl_manifest.kiali]
}

data "kubectl_file_documents" "prometheus" {
  content = file("${path.module}/manifests/prometheus.yaml")
}

# Ingress gateway
resource "helm_release" "istio_ingress" {
  name             = "istio-ingressgateway"
  chart            = "gateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "default"
  create_namespace = true

  version = "1.17.1"

  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "service.ports[0].name"
    value = "status-port"
  }

  set {
    name  = "service.ports[0].port"
    value = 15021
  }

  set {
    name  = "service.ports[0].targetPort"
    value = 15021
  }

  set {
    name  = "service.ports[0].nodePort"
    value = 30021
  }

  set {
    name  = "service.ports[0].protocol"
    value = "TCP"
  }

  set {
    name  = "service.ports[1].name"
    value = "http2"
  }

  set {
    name  = "service.ports[1].port"
    value = 80
  }

  set {
    name  = "service.ports[1].targetPort"
    value = 80
  }

  set {
    name  = "service.ports[1].nodePort"
    value = 30080
  }

  set {
    name  = "service.ports[1].protocol"
    value = "TCP"
  }


  set {
    name  = "service.ports[2].name"
    value = "https"
  }

  set {
    name  = "service.ports[2].port"
    value = 443
  }

  set {
    name  = "service.ports[2].targetPort"
    value = 443
  }

  set {
    name  = "service.ports[2].nodePort"
    value = 30443
  }

  set {
    name  = "service.ports[2].protocol"
    value = "TCP"
  }
}
