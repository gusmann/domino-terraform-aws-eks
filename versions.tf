terraform {
  experiments      = [module_variable_optional_attrs]
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.4.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.1"
    }
  }
}

provider "aws" {
  region = var.region
}
