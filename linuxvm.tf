#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
#*          Linux VM Resources                        #*
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*


#
# - Public IP (To Login to the VM)
#

resource "azurerm_public_ip" "linux-pip" {
    count                             =     var.os_type == "linux" ? 1 : 0
    name                              =     "${var.prefix}-linuxvm-public-ip"
    resource_group_name               =     azurerm_resource_group.rg.name
    location                          =     azurerm_resource_group.rg.location
    allocation_method                 =     "Static"
    tags                              =     var.tags
}

#
# - Network Interface Card
#

resource "azurerm_network_interface" "linux-nic" {
    count                             =     var.os_type == "linux" ? 1 : 0
    name                              =     "${var.prefix}-linuxvm-nic"
    resource_group_name               =     azurerm_resource_group.rg.name
    location                          =     azurerm_resource_group.rg.location
    tags                              =     var.tags
    ip_configuration  {
        name                          =     "${var.prefix}-linuxvm-nic-ipconfig"
        subnet_id                     =     azurerm_subnet.sn.id
        public_ip_address_id          =     azurerm_public_ip.linux-pip[0].id
        private_ip_address_allocation =     "Dynamic"
    }
}


#
# - Linux Virtual Machine
#

resource "azurerm_linux_virtual_machine" "vm" {
    count                             =     var.os_type == "linux" ? 1 : 0
    name                              =     "${var.prefix}-linux-vm"
    resource_group_name               =     azurerm_resource_group.rg.name
    location                          =     azurerm_resource_group.rg.location
    network_interface_ids             =     [azurerm_network_interface.linux-nic[0].id]
    size                              =     "Standard_D2s_v3"
    computer_name                     =     "linux-vm"
    admin_username                    =     azurerm_key_vault_secret.kv["linuxvm-username"].value
    admin_password                    =     azurerm_key_vault_secret.kv["linuxvm-password"].value
    disable_password_authentication   =     false
    allow_extension_operations        =     true

    os_disk  {
        name                          =     "${var.prefix}-vm-os-disk"
        caching                       =     "ReadWrite"
        storage_account_type          =     "StandardSSD_LRS"
        disk_size_gb                  =     64
    }

    source_image_reference {
        publisher                     =     "Canonical"
        offer                         =     "UbuntuServer"
        sku                           =     "16.04-LTS"
        version                       =     "latest"
    }

    tags                              =     var.tags
}

#
# - VM Extension to set up Azure Disk Encryption (Data at Rest)
# 

resource "azurerm_virtual_machine_extension" "linux-ade" {
    count                             =     var.os_type == "linux" ? 1 : 0
    name                              =     "AzureDiskEncryption"
    virtual_machine_id                =     azurerm_linux_virtual_machine.vm[0].id
    publisher                         =     "Microsoft.Azure.Security"
    type                              =     "AzureDiskEncryptionForLinux"
    type_handler_version              =     "1.1"
    auto_upgrade_minor_version        =     true

    settings = <<SETTINGS
    {
        "EncryptionOperation"         :     "EnableEncryption",
        "KeyVaultURL"                 :     "${azurerm_key_vault.kv.vault_uri}",
        "KeyVaultResourceId"          :     "${azurerm_key_vault.kv.id}",
        "KeyEncryptionKeyURL"         :     "${azurerm_key_vault_key.kv.id}",
        "KekVaultResourceId"          :     "${azurerm_key_vault.kv.id}",
        "KeyEncryptionAlgorithm"      :     "RSA-OAEP",
        "VolumeType"                  :     "All"
    }
    SETTINGS

    depends_on                        =     [azurerm_linux_virtual_machine.vm]
}


