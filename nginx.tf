provider "openshift" {
  // Authentication details
  host     = var.openshift_host
  username = var.openshift_username
  password = var.openshift_password
  insecure = true  // Set to true if SSL verification is not required
}

variable "openshift_host" {}
variable "openshift_username" {}
variable "openshift_password" {}

# Define the NGINX application template
resource "openshift_service" "nginx_service" {
  metadata {
    name = var.name
    annotations = {
      description = "Exposes and load balances the application pods"
    }
  }

  spec {
    port {
      name       = "web"
      port       = 8080
      targetPort = 8080
    }

    selector = {
      name = var.name
    }
  }
}

resource "openshift_route" "nginx_route" {
  metadata {
    name = var.name
    annotations = {
      "template.openshift.io/expose-uri" = "http://{.spec.host}{.spec.path}"
    }
  }

  spec {
    host = var.application_domain

    to {
      kind = "Service"
      name = var.name
    }
  }
}

resource "openshift_image_stream" "nginx_image_stream" {
  metadata {
    name = var.name
    annotations = {
      description = "Keeps track of changes in the application image"
    }
  }
}

resource "openshift_build_config" "nginx_build_config" {
  metadata {
    name = var.name
    annotations = {
      description = "Defines how to build the application",
    }
  }

  spec {
    source {
      type = "Git"

      git {
        uri = var.source_repository_url
        ref = var.source_repository_ref
      }

      contextDir = var.context_dir
    }

    strategy {
      type = "Source"

      source_strategy {
        from {
          kind      = "ImageStreamTag"
          namespace = var.namespace
          name      = "nginx:${var.nginx_version}"
        }
      }
    }

    output {
      to {
        kind = "ImageStreamTag"
        name = "${var.name}:latest"
      }
    }

    trigger {
      type = "ImageChange"
    }

    trigger {
      type = "ConfigChange"
    }

    trigger {
      type = "GitHub"

      github {
        secret = var.github_webhook_secret
      }
    }

    trigger {
      type = "Generic"

      generic {
        secret = var.generic_webhook_secret
      }
    }
  }
}

resource "openshift_deployment" "nginx_deployment" {
  metadata {
    name = var.name
    annotations = {
      description = "Defines how to deploy the application server",
    }
  }

  spec {
    replicas = 1

    selector {
      matchLabels = {
        name = var.name
        app  = var.name
      }
    }

    template {
      metadata {
        labels = {
          name = var.name
          app  = var.name
        }
      }

      spec {
        container {
          name  = "nginx-example"
          image = "nginx:${var.nginx_version}"

          port {
            containerPort = 8080
          }

          readiness_probe {
            timeout_seconds      = 3
            initial_delay_seconds = 3

            http_get {
              path = "/"
              port = 8080
            }
          }

          liveness_probe {
            timeout_seconds      = 3
            initial_delay_seconds = 30

            http_get {
              path = "/"
              port = 8080
            }
          }

          resources {
            limits {
              memory = var.memory_limit
            }
          }
        }
      }
    }
  }
}

# Define input variables
variable "name" {
  default     = "nginx-example"
  description = "The name assigned to all of the frontend objects defined in this template."
}

variable "namespace" {
  default     = "openshift"
  description = "The OpenShift Namespace where the ImageStream resides."
}

variable "nginx_version" {
  default     = "1.20-ubi8"
  description = "Version of NGINX image to be used."
}

variable "memory_limit" {
  default     = "512Mi"
  description = "Maximum amount of memory the container can use."
}

variable "source_repository_url" {
  default     = "https://github.com/sclorg/nginx-ex.git"
  description = "The URL of the repository with your application source code."
}

variable "source_repository_ref" {
  description = "Set this to a branch name, tag, or other ref of your repository if you are not using the default branch."
}

variable "context_dir" {
  description = "Set this to the relative path to your project if it is not in the root of your repository."
}

variable "application_domain" {
  description = "The exposed hostname that will route to the nginx service, if left blank a value will be defaulted."
  default     = ""
}

variable "github_webhook_secret" {
  description = "Github trigger secret. A difficult to guess string encoded as part of the webhook URL. Not encrypted."
  default     = "generated-string"  # Replace with actual secret or use a sensitive provider.
}

variable "generic_webhook_secret" {
  description = "A secret string used to configure the Generic webhook."
  default     = "generated-string"  # Replace with actual secret or use a sensitive provider.
}
