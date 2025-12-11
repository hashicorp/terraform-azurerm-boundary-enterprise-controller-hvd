# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.101"
    }
  }
}

provider "azurerm" {
  features {}
}

module "boundary_controller" {
  source = "../.."

  # Common
  friendly_name_prefix  = var.friendly_name_prefix
  location              = var.location
  resource_group_name   = var.resource_group_name
  create_resource_group = var.create_resource_group
  common_tags           = var.common_tags

  # Pre-requisites
  prereqs_key_vault_name                           = var.prereqs_key_vault_name
  prereqs_key_vault_id                             = var.prereqs_key_vault_id
  prereqs_key_vault_rg_name                        = var.prereqs_key_vault_rg_name
  boundary_license_key_vault_secret_id             = var.boundary_license_key_vault_secret_id
  boundary_tls_cert_key_vault_secret_id            = var.boundary_tls_cert_key_vault_secret_id
  boundary_tls_privkey_key_vault_secret_id         = var.boundary_tls_privkey_key_vault_secret_id
  boundary_tls_ca_bundle_key_vault_secret_id       = var.boundary_tls_ca_bundle_key_vault_secret_id
  boundary_database_password_key_vault_secret_name = var.boundary_database_password_key_vault_secret_name

  # Boundary configuration settings
  boundary_fqdn = var.boundary_fqdn

  # Networking
  vnet_id               = var.vnet_id
  api_lb_is_internal    = var.api_lb_is_internal
  api_lb_subnet_id      = var.api_lb_subnet_id
  cluster_lb_subnet_id  = var.cluster_lb_subnet_id
  cluster_lb_private_ip = var.cluster_lb_private_ip
  db_subnet_id          = var.db_subnet_id
  controller_subnet_id  = var.controller_subnet_id
  worker_subnet_id      = var.worker_subnet_id

  # DNS (optional)
  create_boundary_public_dns_record = var.create_boundary_public_dns_record
  public_dns_zone_name              = var.public_dns_zone_name
  public_dns_zone_rg                = var.public_dns_zone_rg

  # Compute
  vm_enable_boot_diagnostics = var.vm_enable_boot_diagnostics
  vm_sku                     = var.vm_sku
  vmss_vm_count              = var.vmss_vm_count
  vm_ssh_public_key          = var.vm_ssh_public_key
  vmss_availability_zones    = var.vmss_availability_zones

  #Key Vault
  key_vault_cidr_allow_list = var.key_vault_cidr_allow_list
}
