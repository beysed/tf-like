# K8S Registry setup by Like

- clone/copy files from this folder
- install [Like](https://github.com/beysed/like)
- run `like registry.like` this will generate `registry.tf` file

Example contains working setup for [registry:2](https://hub.docker.com/_/registry) in k8s local cluster([Docker Desktop](https://www.docker.com/))

Brifly, these lines

```
#include "./k8.like"

$conflate(
    $k8_namespace(k8s)
    $k8_service(registry k8s $k8_node_port(5000 31000))
    $k8_sts(registry k8s
        $k8_spec_volume_dir_hostpath('registry-data' /run/desktop/mnt/host/e/wsl/registry)
        $k8_container(registry "registry:2"
            $k8_container_resources("0.25" "0.50Gi" "0.25" "0.25Gi")
            $k8_container_port(5000)
            $k8_volume_mount('registry-data' "/var/lib/registry")
        )
    )
) | $tf

(err = ($tf | & terraform fmt -)) | $fmt
$err ? ~ "$tf\n$err" % ((~ $fmt) > 'registry.tf')
```

generates
```
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

```