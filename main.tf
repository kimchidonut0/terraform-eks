provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.13.1"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = module.eks.cluster_token
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
  }
  count = var.namespace == "default" ? 0 : 1
}

resource "kubernetes_deployment" "hello" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    labels = {
      app = var.app_name
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.app_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }
      spec {
        container {
          name  = var.app_name
          image = var.container_image
          port {
            container_port = var.container_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hello" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
  }
  spec {
    selector = {
      app = var.app_name
    }
    port {
      port        = var.container_port
      target_port = var.container_port
    }
    type = "LoadBalancer"
  }
}