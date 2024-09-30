# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Resource Group Name
#------------------------------------------------------------------------------
output "resource_group_name" {
  value       = module.boundary_controller.resource_group_name
  description = "Name of the Resource Group."
}

#------------------------------------------------------------------------------
# Boundary
#------------------------------------------------------------------------------
output "url" {
  value       = module.boundary_controller.url
  description = "URL of Boundary Controller based on `boundary_fqdn` input."
}

#------------------------------------------------------------------------------
# Database
#------------------------------------------------------------------------------
output "boundary_database_host" {
  value       = module.boundary_controller.boundary_database_host
  description = "FQDN and port of PostgreSQL Flexible Server."
}

output "boundary_database_name" {
  value       = module.boundary_controller.boundary_database_name
  description = "Name of PostgreSQL Flexible Server database."
}

#------------------------------------------------------------------------------
# Key Vault
#------------------------------------------------------------------------------
output "created_boundary_controller_key_vault_name" {
  value       = module.boundary_controller.created_boundary_controller_key_vault_name
  description = "Name of the Boundary Controller Key Vault."
}

output "created_boundary_worker_key_vault_name" {
  value       = module.boundary_controller.created_boundary_worker_key_vault_name
  description = "Name of the Boundary Worker Key Vault."
}

output "created_boundary_root_key_name" {
  value       = module.boundary_controller.created_boundary_root_key_name
  description = "Name of the created Boundary Root Key."
}

output "created_boundary_recovery_key_name" {
  value       = module.boundary_controller.created_boundary_recovery_key_name
  description = "Name of the created Boundary Recovery Key."
}

output "created_boundary_worker_key_name" {
  value       = module.boundary_controller.created_boundary_worker_key_name
  description = "Name of the created Boundary Worker Key."
}

output "provided_boundary_controller_key_vault_name" {
  value       = module.boundary_controller.provided_boundary_controller_key_vault_name
  description = "Name of the provided Boundary Controller Key Vault."
}

output "provided_boundary_worker_key_vault_name" {
  value       = module.boundary_controller.provided_boundary_worker_key_vault_name
  description = "Name of the provided Boundary Worker Key Vault."
}

output "provided_boundary_root_key_name" {
  value       = module.boundary_controller.provided_boundary_root_key_name
  description = "Name of the provided Boundary Root Key."
}

output "provided_boundary_recovery_key_name" {
  value       = module.boundary_controller.provided_boundary_recovery_key_name
  description = "Name of the provided Boundary Recovery Key."
}

output "provided_boundary_worker_key_name" {
  value       = module.boundary_controller.provided_boundary_worker_key_name
  description = "Name of the provided Boundary Worker Key."
}

#------------------------------------------------------------------------------
# Load Balancer
#------------------------------------------------------------------------------
output "boundary_controller_cluster_lb_private_ip" {
  value       = module.boundary_controller.boundary_controller_cluster_lb_private_ip
  description = "Private IP address of the Boundary Cluster Load Balancer."
}