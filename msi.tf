# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# boundary User-Assigned Identity
#------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "boundary" {
  name                = "${var.friendly_name_prefix}-boundary-controller-msi"
  resource_group_name = local.resource_group_name
  location            = var.location
}

data "azurerm_key_vault" "prereqs" {
  name                = var.prereqs_key_vault_name
  resource_group_name = var.prereqs_key_vault_rg_name
}

resource "azurerm_role_assignment" "boundary_kv_reader" {
  scope                = data.azurerm_key_vault.prereqs.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.boundary.principal_id
}

resource "azurerm_key_vault_access_policy" "boundary_kv_reader" {
  key_vault_id = data.azurerm_key_vault.prereqs.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.boundary.principal_id

  secret_permissions = [
    "Get",
  ]
}

#------------------------------------------------------------------------------
# PostgreSQL Flexible Server User-Assigned Identity
#------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "postgres" {
  count = var.postgres_cmk_key_vault_key_id != null ? 1 : 0

  name                = "${var.friendly_name_prefix}-boundary-postgres-msi"
  resource_group_name = local.resource_group_name
  location            = var.location
}

resource "azurerm_key_vault_access_policy" "postgres_cmk" {
  count = var.postgres_cmk_key_vault_key_id != null && var.postgres_cmk_key_vault_id != null ? 1 : 0

  key_vault_id = var.postgres_cmk_key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.postgres[0].principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey",
  ]
}

#------------------------------------------------------------------------------
# VMSS Disk Encryption Set
#------------------------------------------------------------------------------
data "azurerm_disk_encryption_set" "vmss" {
  count = var.vm_disk_encryption_set_name != null && var.vm_disk_encryption_set_rg != null ? 1 : 0

  name                = var.vm_disk_encryption_set_name
  resource_group_name = var.vm_disk_encryption_set_rg
}

resource "azurerm_role_assignment" "boundary_vmss_disk_encryption_set_reader" {
  count = var.vm_disk_encryption_set_name != null && var.vm_disk_encryption_set_rg != null ? 1 : 0

  scope                = data.azurerm_disk_encryption_set.vmss[0].id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.boundary.principal_id
}

