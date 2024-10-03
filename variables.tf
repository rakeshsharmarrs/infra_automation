variable "namespace" {
  description = "The namespace in which to install NGINX."
  type        = string
}

variable "ocp_url" {
  description = "The OpenShift API server URL."
  type        = string
}

variable "ocp_token" {
  description = "The token used to authenticate to OpenShift."
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The cluster's CA certificate in base64 format."
  type        = string
}
