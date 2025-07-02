variable "region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "The name for the EKS cluster"
  type        = string
  default     = "hello-k8s-cluster"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "hello-kubernetes"
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
  default     = "paulbouwer/hello-kubernetes:1.7"
}

variable "container_port" {
  description = "Port the container exposes"
  type        = number
  default     = 8080
}

variable "namespace" {
  description = "Kubernetes namespace for app"
  type        = string
  default     = "default"
}