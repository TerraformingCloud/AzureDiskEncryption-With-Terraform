
# Terraform Block 

terraform {
    required_providers {
        azurerm =   {
            source  =   "hashicorp/azurerm"
            version =   "~> 2.0"
        }
    }
}

# Provider Block 

provider "azurerm" {
    features {}
}


# Uncomment this Provider Block if you wish to use a Service Principal.

# provider "azurerm" {
#     client_id       =   var.client_id
#     client_secret   =   var.client_secret
#     subscription_id =   var.subscription_id
#     tenant_id       =   var.tenant_id
    
#     features {}
# }

# variable "client_id" {}
# variable "client_secret" {}
# variable "subscription_id" {}
# variable "tenant_id" {}
