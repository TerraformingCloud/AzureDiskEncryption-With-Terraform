#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
#*          Variables               #*
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

variable "prefix" {
    type            =   string
    default         =   "ade"
}


variable "tags" {
    description     =   "Resource Tags"
    type            =   map(string)
    default         =   {
        "deployed_with"    =   "terraform1.0"
        "purpose"          =   "azurediskencryption"
    }
}


variable "os_type" {
    description     =   "Select the OS of your base image. Enter windows or linux"
    validation {
        condition   =   anytrue([
            var.os_type == "windows",
            var.os_type == "linux"
        ])
        error_message = "The value must be either \"windows\" or \"linux\"."
    }
}


variable "kv_secrets" {
    description             =       "Name and Value of keyvault secrets"
    type                    =       map(string)
}



locals {
    rglocation              =       "eastus"
    vnet_cidr               =       "10.0.0.0/16"
    kv_key_permissions      =       ["Create", "Delete", "Get", "List", "Import", "Encrypt", "Decrypt", "Recover", "WrapKey", "UnwrapKey", "Verify", "Sign", "Restore", "Purge", "Update", "Backup",]
    kv_secret_permissions   =       ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set",]
}