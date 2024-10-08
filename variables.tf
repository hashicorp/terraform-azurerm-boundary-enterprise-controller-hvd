# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------
variable "resource_group_name" {
  type        = string
  description = "Name of Resource Group to create."
  default     = "boundary-controller-rg"
}

variable "create_resource_group" {
  type        = bool
  description = "Boolean to create a new Resource Group for this boundary deployment."
  default     = true
}

variable "location" {
  type        = string
  description = "Azure region for this boundary deployment."

  validation {
    condition     = contains(["eastus", "westus", "centralus", "eastus2", "westus2", "westeurope", "northeurope", "southeastasia", "eastasia", "australiaeast", "australiasoutheast", "uksouth", "ukwest", "canadacentral", "canadaeast", "southindia", "centralindia", "westindia", "japaneast", "japanwest", "koreacentral", "koreasouth", "francecentral", "southafricanorth", "uaenorth", "brazilsouth", "switzerlandnorth", "germanywestcentral", "norwayeast", "westcentralus"], var.location)
    error_message = "The location specified is not a valid Azure region."
  }
}

variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix for uniquely naming Azure resources."

  validation {
    condition     = can(regex("^[[:alnum:]]+$", var.friendly_name_prefix)) && length(var.friendly_name_prefix) < 13
    error_message = "Value can only contain alphanumeric characters and must be less than 13 characters."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for taggable Azure resources."
  default     = {}
}

variable "availability_zones" {
  type        = set(string)
  description = "List of Azure Availability Zones to spread boundary resources across."
  default     = ["1", "2", "3"]

  validation {
    condition     = alltrue([for az in var.availability_zones : contains(["1", "2", "3"], az)])
    error_message = "Availability zone must be one of, or a combination of '1', '2', '3'."
  }
}

variable "is_govcloud_region" {
  type        = bool
  description = "Boolean indicating whether this boundary deployment is in an Azure Government Cloud region."
  default     = false
}

#------------------------------------------------------------------------------
# prereqs
#------------------------------------------------------------------------------
variable "prereqs_key_vault_name" {
  type        = string
  description = "Name of the 'prereqs' Key Vault to use for prereqs boundary deployment."
}

variable "prereqs_key_vault_id" {
  type        = string
  description = "ID of the 'prereqs' Key Vault to use for prereqs boundary deployment."
}

variable "prereqs_key_vault_rg_name" {
  type        = string
  description = "Name of the Resource Group where the 'prereqs' Key Vault resides."
}

variable "boundary_license_key_vault_secret_id" {
  type        = string
  description = "ID of Key Vault secret containing boundary license."
}

variable "boundary_tls_cert_key_vault_secret_id" {
  type        = string
  description = "ID of Key Vault secret containing boundary TLS certificate."
}

variable "boundary_tls_privkey_key_vault_secret_id" {
  type        = string
  description = "ID of Key Vault secret containing boundary TLS private key."
}

variable "boundary_tls_ca_bundle_key_vault_secret_id" {
  type        = string
  description = "ID of Key Vault secret containing boundary TLS custom CA bundle."
}

variable "additional_package_names" {
  type        = set(string)
  description = "List of additional repository package names to install"
  default     = []
}
#------------------------------------------------------------------------------
# boundary configuration settings
#------------------------------------------------------------------------------
variable "boundary_fqdn" {
  type        = string
  description = "Fully qualified domain name of boundary instance. This name should resolve to the load balancer IP address and will be what clients use to access boundary."
}

variable "boundary_license_reporting_opt_out" {
  type        = bool
  description = "Boolean to opt out of license reporting."
  default     = false
}

variable "boundary_tls_disable" {
  type        = bool
  description = "Boolean to disable TLS for boundary."
  default     = false
}

variable "boundary_version" {
  type        = string
  description = "Version of Boundary to install."
  default     = "0.17.1+ent"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\+ent$", var.boundary_version))
    error_message = "Value must be in the format 'X.Y.Z+ent'."
  }
}

#------------------------------------------------------------------------------
# Networking
#------------------------------------------------------------------------------
variable "vnet_id" {
  type        = string
  description = "VNet ID where boundary resources will reside."
}

variable "api_lb_subnet_id" {
  type        = string
  description = "Subnet ID for Boundary API load balancer."
  default     = null
}

variable "api_lb_is_internal" {
  type        = bool
  description = "Boolean to create an internal or external Azure Load Balancer for boundary."
  default     = false
}

variable "api_lb_private_ip" {
  type        = string
  description = "Private IP address for internal Azure Load Balancer. Only valid when `lb_is_internal` is `true`."
  default     = null
  validation {
    condition     = var.api_lb_is_internal ? var.api_lb_private_ip != null : true
    error_message = "Private IP address must be provided when `api_lb_is_internal` is `true`."
  }
}

variable "cluster_lb_subnet_id" {
  type        = string
  description = "Subnet ID for Boundary 1ster load balancer."
  default     = null
}

variable "cluster_lb_private_ip" {
  type        = string
  description = "Private IP address for internal Azure Load Balancer."
}

variable "db_subnet_id" {
  type        = string
  description = "Subnet ID for PostgreSQL database."
}

variable "controller_subnet_id" {
  type        = string
  description = "Subnet ID for controller VMs."
}

variable "worker_subnet_id" {
  type        = string
  description = "Subnet ID for worker VMs."
}

#------------------------------------------------------------------------------
# DNS
#------------------------------------------------------------------------------
variable "create_boundary_public_dns_record" {
  type        = bool
  description = "Boolean to create a DNS record for boundary in a public Azure DNS zone. `public_dns_zone_name` must also be provided when `true`."
  default     = false
}

variable "create_boundary_private_dns_record" {
  type        = bool
  description = "Boolean to create a DNS record for boundary in a private Azure DNS zone. `private_dns_zone_name` must also be provided when `true`."
  default     = false
}

variable "public_dns_zone_name" {
  type        = string
  description = "Name of existing public Azure DNS zone to create DNS record in. Required when `create_boundary_public_dns_record` is `true`."
  default     = null
}

variable "public_dns_zone_rg" {
  type        = string
  description = "Name of Resource Group where `public_dns_zone_name` resides. Required when `create_boundary_public_dns_record` is `true`."
  default     = null
}

variable "private_dns_zone_name" {
  type        = string
  description = "Name of existing private Azure DNS zone to create DNS record in. Required when `create_boundary_private_dns_record` is `true`."
  default     = null
}

variable "private_dns_zone_rg" {
  type        = string
  description = "Name of Resource Group where `private_dns_zone_name` resides. Required when `create_boundary_private_dns_record` is `true`."
  default     = null
}

#------------------------------------------------------------------------------
# Virtual Machine Scaleset (VMSS)
#------------------------------------------------------------------------------
variable "vmss_vm_count" {
  type        = number
  description = "Number of VM instances in the VMSS."
  default     = 1
}

variable "vm_sku" {
  type        = string
  description = "SKU for VM size for the VMSS."
  default     = "Standard_D2s_v5"

  validation {
    condition     = can(regex("^[A-Za-z0-9_]+$", var.vm_sku))
    error_message = "Value can only contain alphanumeric characters and underscores."
  }
}

variable "vm_admin_username" {
  type        = string
  description = "Admin username for VMs in VMSS."
  default     = "boundaryadmin"
}

variable "vm_ssh_public_key" {
  type        = string
  description = "SSH public key for VMs in VMSS."
  default     = null
}

variable "vm_custom_image_name" {
  type        = string
  description = "Name of custom VM image to use for VMSS. If not using a custom image, leave this blank."
  default     = null
}

variable "vm_custom_image_rg_name" {
  type        = string
  description = "Resource Group name where the custom VM image resides. Only valid if `vm_custom_image_name` is not null."
  default     = null
}

variable "vm_image_publisher" {
  type        = string
  description = "Publisher of the VM image."
  default     = "Canonical"
}

variable "vm_image_offer" {
  type        = string
  description = "Offer of the VM image."
  default     = "0001-com-ubuntu-server-jammy"
}

variable "vm_image_sku" {
  type        = string
  description = "SKU of the VM image."
  default     = "22_04-lts-gen2"
}

variable "vm_image_version" {
  type        = string
  description = "Version of the VM image."
  default     = "latest"
}

variable "vm_disk_encryption_set_name" {
  type        = string
  description = "Name of the Disk Encryption Set to use for VMSS."
  default     = null
}

variable "vm_disk_encryption_set_rg" {
  type        = string
  description = "Name of the Resource Group where the Disk Encryption Set to use for VMSS exists."
  default     = null
}

variable "vm_enable_boot_diagnostics" {
  type        = bool
  description = "Boolean to enable boot diagnostics for VMSS."
  default     = false
}

variable "vmss_availability_zones" {
  type        = set(string)
  description = "List of Azure Availability Zones to spread the VMSS VM resources across."
  default     = ["1", "2", "3"]

  validation {
    condition     = alltrue([for az in var.vmss_availability_zones : contains(["1", "2", "3"], az)])
    error_message = "Availability zone must be one of, or a combination of '1', '2', '3'."
  }
}

#------------------------------------------------------------------------------
# PostgreSQL
#------------------------------------------------------------------------------
variable "boundary_database_password_key_vault_secret_name" {
  type        = string
  description = "Name of the secret in the Key Vault that contains the boundary database password."
}

variable "postgres_version" {
  type        = number
  description = "PostgreSQL database version."
  default     = 16
}

variable "postgres_sku" {
  type        = string
  description = "PostgreSQL database SKU."
  default     = "GP_Standard_D4ds_v4"
}

variable "postgres_storage_mb" {
  type        = number
  description = "Storage capacity of PostgreSQL Flexible Server (unit is megabytes)."
  default     = 65536
}

variable "postgres_administrator_login" {
  type        = string
  description = "Username for administrator login of PostreSQL database."
  default     = "boundary"
}

variable "postgres_backup_retention_days" {
  type        = number
  description = "Number of days to retain backups of PostgreSQL Flexible Server."
  default     = 35
}

variable "postgres_create_mode" {
  type        = string
  description = "Determines if the PostgreSQL Flexible Server is being created as a new server or as a replica."
  default     = "Default"

  validation {
    condition     = anytrue([var.postgres_create_mode == "Default", var.postgres_create_mode == "Replica"])
    error_message = "Value must be `Default` or `Replica`."
  }
}

variable "boundary_database_name" {
  type        = string
  description = "PostgreSQL database name for boundary."
  default     = "boundary"
}

variable "boundary_database_paramaters" {
  type        = string
  description = "PostgreSQL server parameters for the connection URI. Used to configure the PostgreSQL connection."
  default     = "sslmode=require"
}

variable "create_postgres_private_endpoint" {
  type        = bool
  description = "Boolean to create a private endpoint and private DNS zone for PostgreSQL Flexible Server."
  default     = true
}

variable "postgres_enable_high_availability" {
  type        = bool
  description = "Boolean to enable `ZoneRedundant` high availability with PostgreSQL database."
  default     = false
}

variable "postgres_geo_redundant_backup_enabled" {
  type        = bool
  description = "Boolean to enable PostreSQL geo-redundant backup configuration in paired Azure region."
  default     = true
}

variable "postgres_primary_availability_zone" {
  type        = number
  description = "Number for the availability zone for the primary PostgreSQL Flexible Server instance to reside in."
  default     = 1
}

variable "postgres_secondary_availability_zone" {
  type        = number
  description = "Number for the availability zone for the standby PostgreSQL Flexible Server instance to reside in."
  default     = 2
}

variable "postgres_maintenance_window" {
  type        = map(number)
  description = "Map of maintenance window settings for PostgreSQL Flexible Server."
  default = {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }
}

variable "postgres_cmk_key_vault_key_id" {
  type        = string
  description = "ID of the Key Vault key to use for customer-managed key (CMK) encryption of PostgreSQL Flexible Server database."
  default     = null
}

variable "postgres_cmk_key_vault_id" {
  type        = string
  description = "ID of the Key Vault containing the customer-managed key (CMK) for encrypting the PostgreSQL Flexible Server database."
  default     = null
}

variable "postgres_geo_backup_key_vault_key_id" {
  type        = string
  description = "ID of the Key Vault key to use for customer-managed key (CMK) encryption of PostgreSQL Flexible Server geo-redundant backups. This key must be in the same region as the geo-redundant backup."
  default     = null
}

variable "postgres_geo_backup_user_assigned_identity_id" {
  type        = string
  description = "ID of the User-Assigned Identity to use for customer-managed key (CMK) encryption of PostgreSQL Flexible Server geo-redundant backups. This identity must have 'Get', 'WrapKey', and 'UnwrapKey' permissions to the Key Vault."
  default     = null
}

variable "postgres_source_server_id" {
  type        = string
  description = "ID of the source PostgreSQL Flexible Server to replicate from. Only valid when `is_secondary_region` is `true` and `postgres_create_mode` is `Replica`."
  default     = null
}

#------------------------------------------------------------------------------
# Key Vault
#------------------------------------------------------------------------------
variable "key_vault_cidr_allow_list" {
  type        = list(string)
  description = "List of CIDR blocks to allow access to the Key Vault. This should be the public IP address of the machine running the Terraform deployment."
  default     = []
}

variable "create_boundary_controller_key_vault" {
  type        = bool
  description = "Boolean to create a Key Vault for Boundary Controller."
  default     = true
}

variable "create_boundary_controller_root_key" {
  type        = bool
  description = "Boolean to create a root key in the Boundary Controller Key Vault."
  default     = true
}

variable "create_boundary_controller_recovery_key" {
  type        = bool
  description = "Boolean to create a recovery key in the Boundary Controller Key Vault."
  default     = true
}

variable "create_boundary_worker_key_vault" {
  type        = bool
  description = "Boolean to create a Key Vault for Boundary Worker."
  default     = true
}

variable "create_boundary_worker_key" {
  type        = bool
  description = "Boolean to create the worker key."
  default     = true
}

# --- Existing Key Vault & Keys --- #
variable "boundary_controller_key_vault_rg_name" {
  type        = string
  description = "Name of the existing Resource Group containing the Azure Key Vault to use for Boundary Controller keys."
  default     = null
  validation {
    condition     = var.create_boundary_controller_key_vault == false ? var.boundary_controller_key_vault_rg_name != null : true
    error_message = "Resource Group Name containing the Boundary Controller Key Vault must be provided if `create_boundary_controller_key_vault` is set to `false`."
  }
  validation {
    condition     = var.boundary_controller_key_vault_name != null ? var.boundary_controller_key_vault_rg_name != null : true
    error_message = "Value of the boundary_controller_key_vault_rg_name is required when boundary_controller_key_vault_name is provided"
  }
}

variable "boundary_controller_key_vault_name" {
  type        = string
  description = "Name of the existing Azure Key Vault to use for Boundary Controller keys."
  default     = null
  validation {
    condition     = var.create_boundary_controller_key_vault == false ? var.boundary_controller_key_vault_name != null : true
    error_message = "Key Vault Name must be provided if `create_boundary_controller_key_vault` is set to `false`."
  }
}

variable "root_key_name" {
  type        = string
  description = "Name of the existing root key in the Boundary Controller Key Vault."
  default     = null
}

variable "recovery_key_name" {
  type        = string
  description = "Name of the existing recovery key in the Boundary Controller Key Vault."
  default     = null
}

variable "boundary_worker_key_vault_rg_name" {
  type        = string
  description = "Name of the existing Resource Group containing the Azure Key Vault to use for Boundary Worker keys."
  default     = null
  validation {
    condition     = var.create_boundary_worker_key_vault == false ? var.boundary_worker_key_vault_rg_name != null : true
    error_message = "Resource Group Name containing the Boundary Worker Key Vault must be provided if `create_boundary_worker_key_vault` is set to `false`."
  }
  validation {
    condition     = var.boundary_worker_key_vault_name != null ? var.boundary_worker_key_vault_rg_name != null : true
    error_message = "Value of the boundary_worker_key_vault_rg_name is required when boundary_worker_key_vault_name is provided"
  }
}

variable "boundary_worker_key_vault_name" {
  type        = string
  description = "Name of the existing Azure Key Vault to use for Boundary Worker keys."
  default     = null
  validation {
    condition     = var.create_boundary_worker_key_vault == false ? var.boundary_worker_key_vault_name != null : true
    error_message = "Key Vault Name must be provided if `create_boundary_worker_key_vault` is set to `false`."
  }
}

variable "worker_key_name" {
  type        = string
  description = "Name of the existing worker key in the Boundary Worker Key Vault."
  default     = null
}
