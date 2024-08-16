resource "kubernetes_namespace" "k8s" {
  metadata {
    name = "k8s"
  }
}
resource "kubernetes_service" "registry" {
  metadata {
    namespace = "k8s"
    name      = "registry"
  }

  spec {
    selector = {
      k8s-app = "registry"
    }
    port {
      port        = 5000
      target_port = 5000
      node_port   = 31000
    }

    type = "NodePort"
  }
}
resource "kubernetes_stateful_set" "registry" {
  metadata {
    name      = "registry"
    namespace = "k8s"
  }

  spec {
    service_name = "registry"

    selector {
      match_labels = {
        k8s-app = "registry"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "registry"
        }
      }
      spec {
        volume {
          name = "registry-data"
          host_path {
            type = "Directory"
            path = "/run/desktop/mnt/host/e/wsl/registry"
          }
        }
        container {
          name  = "registry"
          image = "registry:2"
          resources {
            limits = {
              cpu    = "0.25"
              memory = "0.50Gi"
            }

            requests = {
              cpu    = "0.25"
              memory = "0.25Gi"
            }
          }
          port {
            container_port = 5000
          }
          volume_mount {
            mount_path = "/var/lib/registry"
            name       = "registry-data"
          }

        }

      }
    }
  }
}
