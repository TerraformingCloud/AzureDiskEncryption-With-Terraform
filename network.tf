#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
#*          Networking Resources                      #*
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

#
# - Resource Group
#

resource "azurerm_resource_group" "rg" {
    name                  =     "${var.prefix}-rg"
    location              =     local.rglocation
    tags                  =     var.tags
}

#
# - Virtual Network
#

resource "azurerm_virtual_network" "vnet" {
    name                  =   "${var.prefix}-vnet"
    resource_group_name   =   azurerm_resource_group.rg.name
    location              =   azurerm_resource_group.rg.location
    address_space         =   [local.vnet_cidr]
    tags                  =   var.tags
}

#
# - Subnet
#

resource "azurerm_subnet" "sn" {
    name                  =   "${var.prefix}-subnet"
    resource_group_name   =   azurerm_resource_group.rg.name
    virtual_network_name  =   azurerm_virtual_network.vnet.name
    address_prefixes      =   [cidrsubnet(local.vnet_cidr, 8, 1)]
}

#
# - Network Security Group 
#

resource "azurerm_network_security_group" "nsg" {
    name                        =       "${var.prefix}-nsg"
    resource_group_name         =       azurerm_resource_group.rg.name
    location                    =       azurerm_resource_group.rg.location
    tags                        =       var.tags
}

resource "azurerm_network_security_rule" "nsg-rule" {
    resource_group_name         =       azurerm_resource_group.rg.name
    network_security_group_name =       azurerm_network_security_group.nsg.name
    name                        =       "Allow_Inbound"
    priority                    =       1000
    direction                   =       "Inbound"
    access                      =       "Allow"
    protocol                    =       "Tcp"
    source_port_range           =       "*"
    destination_port_range      =       var.os_type == "windows" ? 3389 : 22
    source_address_prefix       =       "*" 
    destination_address_prefix  =       "*"    
}



#
# - Subnet-NSG Association
#

resource "azurerm_subnet_network_security_group_association" "subnet-nsg" {
    subnet_id                    =       azurerm_subnet.sn.id
    network_security_group_id    =       azurerm_network_security_group.nsg.id
}

