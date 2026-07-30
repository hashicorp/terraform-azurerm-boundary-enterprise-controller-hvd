# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Existing Key Vault & Keys
#------------------------------------------------------------------------------
data "azurerm_key_vault" "boundary_controller" {
  count = var.create_boundary_controller_key_vault ? 0 : 1

  name                = var.boundary_controller_key_vault_name
  resource_group_name = var.boundary_controller_key_vault_rg_name
}

data "azurerm_key_vault_key" "root" {
  count = var.root_key_name == null ? 0 : 1

  name         = var.root_key_name
  key_vault_id = data.azurerm_key_vault.boundary_controller[0].id
}

data "azurerm_key_vault_key" "recovery" {
  count = var.recovery_key_name == null ? 0 : 1

  name         = var.recovery_key_name
  key_vault_id = data.azurerm_key_vault.boundary_controller[0].id
}

data "azurerm_key_vault" "boundary_worker" {
  count = var.create_boundary_worker_key_vault ? 0 : 1

  name                = var.boundary_worker_key_vault_name
  resource_group_name = var.boundary_worker_key_vault_rg_name
}

data "azurerm_key_vault_key" "worker" {
  count = var.worker_key_name == null ? 0 : 1

  name         = var.boundary_worker_key_vault_name
  key_vault_id = data.azurerm_key_vault.boundary_worker[0].id
}

#------------------------------------------------------------------------------
# Key Vault, Access Policy, Keys
#------------------------------------------------------------------------------

# --- Controller --- #
resource "azurerm_key_vault" "boundary_controller" {
  count = var.create_boundary_controller_key_vault ? 1 : 0

  name                       = "${var.friendly_name_prefix}-boundary-con"
  location                   = var.location
  resource_group_name        = local.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment     = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  enable_rbac_authorization  = var.use_key_vault_rbac
  sku_name                   = "standard"

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.key_vault_cidr_allow_list
    virtual_network_subnet_ids = [var.controller_subnet_id, var.worker_subnet_id]
  }

  tags = merge(
    { "Name" = "${var.friendly_name_prefix}-boundary-controller-kv" },
    var.common_tags
  )
}

resource "azurerm_key_vault_access_policy" "controller_key_vault_controller" {
  count = var.use_key_vault_rbac ? 0 : 1

  key_vault_id = var.create_boundary_controller_key_vault ? azurerm_key_vault.boundary_controller[0].id : data.azurerm_key_vault.boundary_controller[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.boundary.principal_id

  key_permissions = [
    "Get", "List", "Update", "Create", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign",
  ]
}

resource "azurerm_role_assignment" "controller_key_vault_crypto_officer" {
  count = var.use_key_vault_rbac ? 1 : 0

  scope                = var.create_boundary_controller_key_vault ? azurerm_key_vault.boundary_controller[0].id : data.azurerm_key_vault.boundary_controller[0].id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = azurerm_user_assigned_identity.boundary.principal_id
}

resource "azurerm_key_vault_access_policy" "admin_controller" {
  count = var.use_key_vault_rbac ? 0 : 1

  key_vault_id = var.create_boundary_controller_key_vault ? azurerm_key_vault.boundary_controller[0].id : data.azurerm_key_vault.boundary_controller[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Update", "Restore", "Backup", "Import", "Create", "Recover", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Delete", "Purge", "GetRotationPolicy", "SetRotationPolicy"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge",
  ]

  certificate_permissions = [
    "Get", "List", "Create", "Import", "Delete", "Update", "Purge",
  ]
}

resource "azurerm_role_assignment" "admin_controller" {
  count = var.use_key_vault_rbac ? 1 : 0

  scope                = var.create_boundary_controller_key_vault ? azurerm_key_vault.boundary_controller[0].id : data.azurerm_key_vault.boundary_controller[0].id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_key" "root" {
  count = var.create_boundary_controller_root_key ? 1 : 0

  name         = "root"
  key_vault_id = var.create_boundary_controller_key_vault ? azurerm_key_vault.boundary_controller[0].id : data.azurerm_key_vault.boundary_controller[0].id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  depends_on = [
    azurerm_key_vault_access_policy.admin_controller,
    azurerm_role_assignment.admin_controller,
  ]
}

resource "azurerm_key_vault_key" "recovery" {
  count = var.create_boundary_controller_recovery_key ? 1 : 0

  name         = "recovery"
  key_vault_id = var.create_boundary_controller_key_vault ? azurerm_key_vault.boundary_controller[0].id : data.azurerm_key_vault.boundary_controller[0].id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  depends_on = [
    azurerm_key_vault_access_policy.admin_controller,
    azurerm_role_assignment.admin_controller,
  ]
}

# --- Worker --- #
resource "azurerm_key_vault" "boundary_worker" {
  count = var.create_boundary_worker_key ? 1 : 0

  name                       = "${var.friendly_name_prefix}-boundary-work"
  location                   = var.location
  resource_group_name        = local.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment     = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  enable_rbac_authorization  = var.use_key_vault_rbac
  sku_name                   = "standard"

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.key_vault_cidr_allow_list
    virtual_network_subnet_ids = [var.controller_subnet_id, var.worker_subnet_id]
  }

  tags = merge(
    { "Name" = "${var.friendly_name_prefix}-boundary-worker-kv" },
    var.common_tags
  )
}

resource "azurerm_key_vault_access_policy" "worker_key_vault_controller" {
  count = var.use_key_vault_rbac ? 0 : 1

  key_vault_id = var.create_boundary_worker_key_vault ? azurerm_key_vault.boundary_worker[0].id : data.azurerm_key_vault.boundary_worker[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.boundary.principal_id

  key_permissions = [
    "Get", "List", "Update", "Create", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign",
  ]
}

resource "azurerm_role_assignment" "worker_key_vault_crypto_officer" {
  count = var.use_key_vault_rbac ? 1 : 0

  scope                = var.create_boundary_worker_key_vault ? azurerm_key_vault.boundary_worker[0].id : data.azurerm_key_vault.boundary_worker[0].id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = azurerm_user_assigned_identity.boundary.principal_id
}

resource "azurerm_key_vault_access_policy" "admin_worker" {
  count = var.use_key_vault_rbac ? 0 : 1

  key_vault_id = var.create_boundary_worker_key_vault ? azurerm_key_vault.boundary_worker[0].id : data.azurerm_key_vault.boundary_worker[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Update", "Restore", "Backup", "Import", "Create", "Recover", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Delete", "Purge", "GetRotationPolicy", "SetRotationPolicy"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge",
  ]

  certificate_permissions = [
    "Get", "List", "Create", "Import", "Delete", "Update", "Purge",
  ]
}

resource "azurerm_role_assignment" "admin_worker" {
  count = var.use_key_vault_rbac ? 1 : 0

  scope                = var.create_boundary_worker_key_vault ? azurerm_key_vault.boundary_worker[0].id : data.azurerm_key_vault.boundary_worker[0].id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_key" "worker" {
  count = var.create_boundary_worker_key ? 1 : 0

  name         = "worker"
  key_vault_id = var.create_boundary_worker_key_vault ? azurerm_key_vault.boundary_worker[0].id : data.azurerm_key_vault.boundary_worker[0].id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  depends_on = [
    azurerm_key_vault_access_policy.admin_worker,
    azurerm_role_assignment.admin_worker,
  ]
}
