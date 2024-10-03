variable "ocp_url" {
  description = "The URL of the OpenShift API (with https://)."
  type        = string
}

variable "ocp_username" {
  description = "Username for OpenShift authentication."
  type        = string
}

variable "ocp_password" {
  description = "Password for OpenShift authentication."
  type        = string
}

variable "namespace" {
  description = "The namespace to deploy the application."
  type        = string
  default     = "default"
}
