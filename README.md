# Azure Disk Encryption With Terraform

Create a Virtual machine [Windows 10 VM or a Linux VM (Ubuntu 16.04-LTS)] in Azure and enable `Azure Disk Encryption` (encrypt the OS disks and Data disks (Data at Rest)) using Terraform.

## MS Docs Links

- [The official documentation of Azure Disk Encryption on VMs and VMSS](https://docs.microsoft.com/en-us/azure/security/fundamentals/azure-disk-encryption-vms-vmss)

- [Azure Disk Encryption for Windows VMs](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disk-encryption-overview)

- [Azure Disk Encryption for Linux VMs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/disk-encryption-overview)

## Prerequisites

- An azure account (Free trial is good enough). [If you don't have an account, you can create one from here.](https://azure.microsoft.com/en-us/free/)
- Terraform installed on your machine. [Download Terraform from here.](https://www.terraform.io/downloads.html)

## Authenticate Terraform to your azure account

In this example, I have used `az login` from the VS Code terminal to authenticate to my azure account. Terraform will use this information to connect to your account. If you wish to use a service principal, uncomment the `Provider` block with service principal variables and provide the value at run time or store them as Environment variables.

## Resource List

|   Resource Type                                   |     Resource Name in Terraform                                    |
|   ---                                             |     ---                                                           |
|   Resource Group                                  |     azurerm_resource_group                                        |
|   Virtual Network                                 |     azurerm_virtual_network                                       |
|   Subnet                                          |     azurerm_subnet                                                |
|   Network Security Group                          |     azurerm_network_security_group                                |
|   Network Security Rule (RDP or SSH)              |     azurerm_network_security_rule                                 |
|   Subnet-NSG Association                          |     azurerm_subnet_network_security_group_association             |
|   Public IP                                       |     azurerm_public_ip                                             |
|   KeyVault with an Access Policy                  |     azurerm_key_vault                                             |
|   KeyVault Key                                    |     azurerm_key_vault_key                                         |
|   KeyVault Secrets                                |     azurerm_key_vault_secret                                      |
|   Network Interface                               |     azurerm_network_interface                                     |
|   Virtual Machine (Either Windows 10 or Ubuntu)   |     azurerm_windows_virtual_machine for windows 10, azurerm_linux_virtual_machine for Ubuntu                |
|   Virtual Machine Extension (ADE)                 |     azurerm_virtual_machine_extension                             |

## Operating System of the Virtual Machine 

This module contains both Windows 10 and Linux (Ubuntu) VM code in this repo. Terraform will deploy the VM based on your input for the variable `os_type`. If you enter 'windows', terraform will create a Windows 10 VM. If you enter 'linux', terraform will create an Ubuntu machine.

## NSG Security rule - Inbound RDP or SSH 

The network security rule resource (`azurerm_network_security_rule` in `network.tf`) enables RDP or SSH access to all IPs. If you want to limit the access only to your machine, replace the value of `source_address_prefix` from `*` to your IP address. You can findout your ip address by running the command `curl ifconfig.me` or from a simple google search.

## Terraform.tfvars file

We need to provide the values for a couple of variables when you run `terraform plan` and `terraform apply`.
I have included a `terraform.tfvars` file in this repo for your convienience. It's not recommended to checkin this file to your source code repository as it contains sensitive information. You should add this file to `.gitignore` before you push your code.

## Commands to run

``` bash
az login            # To authenticate to your azure account
terraform init      # Initialises Terraform 
terraform validate  # Checks for syntax errors
terraform plan      # Prints your infrastructure plan
terraform apply     # Deploys the infrastructure 
terraform destroy   # To clean up your resources
```
