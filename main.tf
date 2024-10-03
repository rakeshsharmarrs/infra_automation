provider "kubernetes" {
  host                   = var.ocp_url
  token                  = var.ocp_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)

  load_config_file = false  # Disable automatic kubeconfig loading
}

resource "kubernetes_namespace" "nginx_namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "nginx_deployment" {
  metadata {
    name      = "nginx-deployment"
    namespace = kubernetes_namespace.nginx_namespace.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }

          resources {
            limits {
              memory = "512Mi"
              cpu    = "500m"
            }
            requests {
              memory = "256Mi"
              cpu    = "250m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_service" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.nginx_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}
