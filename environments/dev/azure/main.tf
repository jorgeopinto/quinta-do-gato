terraform {

  required_version = ">=1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.63.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.40.0"
    }
  }
  
}

provider "azurerm" {
  features {}
}

provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      owner      = "jorgepinto"
      managed-by = "terraform"
    }
  }

}

module "networking" {
  source = "../../../modules/azure/network"
  resource_group_name = "quinta-do-gato_dev"
  HUB_VNET = ["10.0.0.0/16"]
  Azure_Subnet_names = [
    "compute-subnet",
    "storage-subnet"
    ]
  Azure_Subnets_prefixes = [
    "10.0.1.0/24", #compute-subnet
    "10.0.2.0/24" #storage-subnet
  ]
}