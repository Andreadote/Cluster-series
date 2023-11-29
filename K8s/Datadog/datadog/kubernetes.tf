resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
  }
}

resource "kubernetes_deployment" "demo" {
  metadata {
    name      = var.application_name
    namespace = kubernetes_namespace.demo.id
    labels = {
      app = var.application_name
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = var.application_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.application_name
        }
      }

      spec {
        container {
          image = "rajhisaifeddine/demo:datadog"
          name  = var.application_name
        }
      }
    }
  }
}

resource "kubernetes_service" "demo" {
  metadata {
    name      = var.application_name
    namespace = kubernetes_namespace.demo.id
  }
  spec {
    selector = {
      app = kubernetes_deployment.demo.metadata[0].labels.app
    }
    port {
      port        = 8080
      target_port = 80
    }
    type = "LoadBalancer"
  }
}

output "demo_endpoint" {
  value = "${kubernetes_service.demo.status[0].load_balancer[0].ingress[0].hostname}:8080"
}