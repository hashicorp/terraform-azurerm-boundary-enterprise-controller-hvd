# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Custom Data (cloud-init) arguments
#------------------------------------------------------------------------------
locals {
  custom_startup_script_template = var.custom_startup_script_template != null ? "${path.cwd}/templates/${var.custom_startup_script_template}" : "${path.module}/templates/boundary_custom_data.sh.tpl"
  custom_data_args = {
    # used to set azure-cli context to AzureUSGovernment
    is_govcloud_region = var.is_govcloud_region

    # https://developer.hashicorp.com/boundary/docs/configuration/controller

    # prereqs
    boundary_license_key_vault_secret_id       = var.boundary_license_key_vault_secret_id
    boundary_tls_cert_key_vault_secret_id      = var.boundary_tls_cert_key_vault_secret_id
    boundary_tls_privkey_key_vault_secret_id   = var.boundary_tls_privkey_key_vault_secret_id
    boundary_tls_ca_bundle_key_vault_secret_id = var.boundary_tls_ca_bundle_key_vault_secret_id == null ? "NONE" : var.boundary_tls_ca_bundle_key_vault_secret_id
    additional_package_names                   = join(" ", var.additional_package_names)

    # Boundary settings
    boundary_version     = var.boundary_version
    systemd_dir          = "/etc/systemd/system",
    boundary_dir_bin     = "/usr/bin",
    boundary_dir_config  = "/etc/boundary.d",
    boundary_dir_home    = "/opt/boundary",
    boundary_install_url = format("https://releases.hashicorp.com/boundary/%s/boundary_%s_linux_amd64.zip", var.boundary_version, var.boundary_version),
    boundary_tls_disable = var.boundary_tls_disable

    # Database settings
    boundary_database_host     = "${azurerm_postgresql_flexible_server.boundary.fqdn}:5432"
    boundary_database_name     = var.boundary_database_name
    boundary_database_user     = azurerm_postgresql_flexible_server.boundary.administrator_login
    boundary_database_password = azurerm_postgresql_flexible_server.boundary.administrator_password

    # key_vault settings
    tenant_id                 = data.azurerm_client_config.current.tenant_id
    controller_key_vault_name = azurerm_key_vault.boundary_controller[0].name
    worker_key_vault_name     = azurerm_key_vault.boundary_worker[0].name
    controller_key_vault_name = var.boundary_controller_key_vault_name != null ? data.azurerm_key_vault.boundary_controller[0].name : azurerm_key_vault.boundary_controller[0].name
    worker_key_vault_name     = var.boundary_worker_key_vault_name != null ? data.azurerm_key_vault.boundary_worker[0].name : azurerm_key_vault.boundary_worker[0].name
    root_key_name             = var.root_key_name != null ? data.azurerm_key_vault_key.root[0].name : azurerm_key_vault_key.root[0].name
    recovery_key_name         = var.recovery_key_name != null ? data.azurerm_key_vault_key.recovery[0].name : azurerm_key_vault_key.recovery[0].name
    worker_key_name           = var.worker_key_name != null ? data.azurerm_key_vault_key.worker[0].name : azurerm_key_vault_key.worker[0].name
  }
}



#------------------------------------------------------------------------------
# Virtual Machine Scale Set (VMSS)
#------------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine_scale_set" "boundary" {
  name                = "${var.friendly_name_prefix}-boundary-controller-vmss"
  resource_group_name = local.resource_group_name
  location            = var.location
  instances           = var.vmss_vm_count
  sku                 = var.vm_sku
  admin_username      = var.vm_admin_username
  overprovision       = false
  upgrade_mode        = "Manual"
  zone_balance        = true
  zones               = var.vmss_availability_zones
  health_probe_id     = azurerm_lb_probe.boundary_api.id
  custom_data         = base64encode(templatefile("${local.custom_startup_script_template}", local.custom_data_args))

  scale_in {
    rule = "OldestVM"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.boundary.id]
  }

  dynamic "admin_ssh_key" {
    for_each = var.vm_ssh_public_key != null ? [1] : []

    content {
      username   = var.vm_admin_username
      public_key = var.vm_ssh_public_key
    }
  }

  source_image_id = var.vm_custom_image_name != null ? data.azurerm_image.custom[0].id : null

  dynamic "source_image_reference" {
    for_each = var.vm_custom_image_name == null ? [true] : []

    content {
      publisher = local.vm_image_publisher
      offer     = local.vm_image_offer
      sku       = local.vm_image_sku
      version   = data.azurerm_platform_image.latest_os_image.version
    }
  }

  network_interface {
    name    = "boundary-vm-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.controller_subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.boundary_api.id, azurerm_lb_backend_address_pool.boundary_cluster.id]
    }
  }

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_size_gb           = 64
    disk_encryption_set_id = var.vm_disk_encryption_set_name != null && var.vm_disk_encryption_set_rg != null ? data.azurerm_disk_encryption_set.vmss[0].id : null
  }

  automatic_instance_repair {
    enabled      = true
    grace_period = "PT10M"
  }

  dynamic "boot_diagnostics" {
    for_each = var.vm_enable_boot_diagnostics == true ? [1] : []
    content {}
  }

  tags = merge(
    { "Name" = "${var.friendly_name_prefix}-boundary-vmss" },
    var.common_tags
  )
}

# ------------------------------------------------------------------------------
# Debug rendered boundary custom_data script from template
# ------------------------------------------------------------------------------
# Uncomment this block to debug the rendered boundary custom_data script
# resource "local_file" "debug_custom_data" {
#   content  = templatefile("${path.module}/templates/boundary_custom_data.sh.tpl", local.custom_data_args)
#   filename = "${path.module}/debug/debug_boundary_custom_data.sh"
# }
