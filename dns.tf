# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# DNS Zone lookup
#------------------------------------------------------------------------------
data "azurerm_dns_zone" "boundary" {
  count = var.create_boundary_public_dns_record == true && var.public_dns_zone_name != null ? 1 : 0

  name                = var.public_dns_zone_name
  resource_group_name = var.public_dns_zone_rg
}

data "azurerm_private_dns_zone" "boundary" {
  count = var.create_boundary_private_dns_record == true && var.private_dns_zone_name != null ? 1 : 0

  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_rg
}

#------------------------------------------------------------------------------
# DNS A Record
#------------------------------------------------------------------------------
locals {
  boundary_hostname_public  = var.create_boundary_public_dns_record == true && var.public_dns_zone_name != null ? trimsuffix(substr(var.boundary_fqdn, 0, length(var.boundary_fqdn) - length(var.public_dns_zone_name) - 1), ".") : var.boundary_fqdn
  boundary_hostname_private = var.create_boundary_private_dns_record == true && var.private_dns_zone_name != null ? trim(split(var.private_dns_zone_name, var.boundary_fqdn)[0], ".") : var.boundary_fqdn
}

resource "azurerm_dns_a_record" "boundary" {
  count = var.create_boundary_public_dns_record == true && var.public_dns_zone_name != null ? 1 : 0

  name                = local.boundary_hostname_public
  resource_group_name = var.public_dns_zone_rg
  zone_name           = data.azurerm_dns_zone.boundary[0].name
  ttl                 = 300
  records             = var.api_lb_is_internal == true ? [azurerm_lb.boundary_api.private_ip_address] : null
  target_resource_id  = var.api_lb_is_internal == false ? azurerm_public_ip.boundary_api_lb[0].id : null
  tags                = var.common_tags
}

resource "azurerm_private_dns_a_record" "boundary" {
  count = var.create_boundary_private_dns_record == true && var.private_dns_zone_name != null ? 1 : 0

  name                = local.boundary_hostname_private
  resource_group_name = var.private_dns_zone_rg
  zone_name           = data.azurerm_private_dns_zone.boundary[0].name
  ttl                 = 300
  records             = var.api_lb_is_internal == true ? [azurerm_lb.boundary_api.private_ip_address] : null
  tags                = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "boundary" {
  count = var.create_boundary_private_dns_record == true && var.private_dns_zone_name != null ? 1 : 0

  name                  = "${var.friendly_name_prefix}-boundary-priv-dns-zone-vnet-link"
  resource_group_name   = var.private_dns_zone_rg
  private_dns_zone_name = data.azurerm_private_dns_zone.boundary[0].name
  virtual_network_id    = var.vnet_id
  tags                  = var.common_tags
}