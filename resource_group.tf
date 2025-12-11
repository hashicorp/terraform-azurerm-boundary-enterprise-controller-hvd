# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

resource "azurerm_resource_group" "boundary" {
  count = var.create_resource_group == true ? 1 : 0

  name     = var.resource_group_name
  location = var.location

  tags = merge(
    { "Name" = var.resource_group_name },
    var.common_tags
  )
}

// Allow users to bring their own Resource Group
// or let this module create a new one.
locals {
  resource_group_name = (
    var.create_resource_group == true ?
    azurerm_resource_group.boundary[0].name
    : var.resource_group_name
  )
}
