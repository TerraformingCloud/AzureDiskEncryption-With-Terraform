#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
#*          KeyVault Resources                        #*
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

#
# - Data Source to fetch Tenant_ID and Object_ID
#

data "azurerm_client_config" "current" {}

#
# - Random number to append to the Key Vault name
#

resource "random_integer" "random" {
    min                             =       11111
    max                             =       99999
}

#
# - KeyVault with an access policy 
#

resource "azurerm_key_vault" "kv" {
    name                            =       "${var.prefix}kv${random_integer.random.result}"
    resource_group_name             =       azurerm_resource_group.rg.name
    location                        =       azurerm_resource_group.rg.location
    enabled_for_deployment          =       true
    enabled_for_disk_encryption     =       true
    tenant_id                       =       data.azurerm_client_config.current.tenant_id
    sku_name                        =       "standard"
    tags                            =       var.tags

    access_policy  {
        tenant_id                   =       data.azurerm_client_config.current.tenant_id
        object_id                   =       data.azurerm_client_config.current.object_id
        key_permissions             =       local.kv_key_permissions
        secret_permissions          =       local.kv_secret_permissions
    }
}

#
# - Key Vault Key (Required for Azure Disk Encryption)
#

resource "azurerm_key_vault_key" "kv" {
    name                            =       "${var.prefix}-vm-ade-kek"
    key_vault_id                    =       azurerm_key_vault.kv.id
    key_type                        =       "RSA"
    key_size                        =       2048
    key_opts                        =       ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey",]
}


#
# - Key Vault Secrets (To store and fetch the VM login credentials)
#

resource "azurerm_key_vault_secret" "kv" {
    for_each                        =       var.kv_secrets
    name                            =       each.key
    key_vault_id                    =       azurerm_key_vault.kv.id
    value                           =       each.value
}

