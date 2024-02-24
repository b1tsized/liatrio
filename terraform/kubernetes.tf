# ECR Credentials Secret
resource "kubernetes_secret" "docker" {
  metadata {
    name = "ecr-cfg"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${data.aws_ecr_authorization_token.token.proxy_endpoint}" = {
          auth = "${data.aws_ecr_authorization_token.token.authorization_token}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

# EKS Container Deployment
resource "kubernetes_deployment" "liatrio_go" {
  metadata {
    name = "liatrio-go-container"
    labels = {
      App = "LiatrioGoContainer"
    }
  }

  spec {
    selector {
      match_labels = {
        App = "LiatrioGoContainer"
      }
    }
    template {
      metadata {
        labels = {
          App = "LiatrioGoContainer"
        }
      }
      spec {
        image_pull_secrets {
          name = "ecr-cfg"
        }
        container {
          image             = module.lambda_docker-build.image_uri
          name              = "liatrio-image"
          image_pull_policy = "Always"

          port {
            container_port = 5000
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_secret.docker,
  ]
}

# EKS Service ELB
resource "kubernetes_service" "liatrio_go" {
  metadata {
    name = "liatrio-go-container"
  }
  spec {
    selector = {
      App = kubernetes_deployment.liatrio_go.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}