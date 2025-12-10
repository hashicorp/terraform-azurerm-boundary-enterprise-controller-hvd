# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Resource Group Name
#------------------------------------------------------------------------------
output "resource_group_name" {
  value       = local.resource_group_name
  description = "Name of the Resource Group."
}

#------------------------------------------------------------------------------
# Boundary URLs
#------------------------------------------------------------------------------
output "url" {
  value       = "https://${var.boundary_fqdn}"
  description = "URL of Boundary Controller based on `boundary_fqdn` input."
}

#------------------------------------------------------------------------------
# Database
#------------------------------------------------------------------------------
output "boundary_database_host" {
  value       = "${azurerm_postgresql_flexible_server.boundary.fqdn}:5432"
  description = "FQDN and port of PostgreSQL Flexible Server."
}

output "boundary_database_name" {
  value       = azurerm_postgresql_flexible_server_database.boundary.name
  description = "Name of PostgreSQL Flexible Server database."
}

#------------------------------------------------------------------------------
# Key Vault
#------------------------------------------------------------------------------
output "created_boundary_controller_key_vault_name" {
  value       = try(azurerm_key_vault.boundary_controller[0].name, null)
  description = "Name of the created Boundary Controller Key Vault."
}

output "created_boundary_worker_key_vault_name" {
  value       = try(azurerm_key_vault.boundary_worker[0].name, null)
  description = "Name of the created Boundary Worker Key Vault."
}

output "created_boundary_root_key_name" {
  value       = try(azurerm_key_vault_key.root[0].name, null)
  description = "Name of the created Boundary Root Key."
}

output "created_boundary_recovery_key_name" {
  value       = try(azurerm_key_vault_key.recovery[0].name, null)
  description = "Name of the created Boundary Recovery Key."
}

output "created_boundary_worker_key_name" {
  value       = try(azurerm_key_vault_key.worker[0].name, null)
  description = "Name of the created Boundary Worker Key."
}

output "provided_boundary_controller_key_vault_name" {
  value       = try(data.azurerm_key_vault.boundary_controller[0].name, null)
  description = "Name of the provided Boundary Controller Key Vault."
}

output "provided_boundary_worker_key_vault_name" {
  value       = try(data.azurerm_key_vault.boundary_worker[0].name, null)
  description = "Name of the provided Boundary Worker Key Vault."
}

output "provided_boundary_root_key_name" {
  value       = try(data.azurerm_key_vault_key.root[0].name, null)
  description = "Name of the provided Boundary Root Key."
}

output "provided_boundary_recovery_key_name" {
  value       = try(data.azurerm_key_vault_key.recovery[0].name, null)
  description = "Name of the provided Boundary Recovery Key."
}

output "provided_boundary_worker_key_name" {
  value       = try(data.azurerm_key_vault_key.worker[0].name, null)
  description = "Name of the provided Boundary Worker Key."
}

#------------------------------------------------------------------------------
# Load Balancer
#------------------------------------------------------------------------------
output "boundary_controller_cluster_lb_private_ip" {
  value       = azurerm_lb.boundary_cluster.frontend_ip_configuration[0].private_ip_address
  description = "Private IP address of the Boundary Cluster Load Balancer."
}