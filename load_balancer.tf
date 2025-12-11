# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# API Load Balancer
#------------------------------------------------------------------------------
locals {
  api_lb_frontend_name_suffix = var.api_lb_is_internal == true ? "internal" : "external"
}

resource "azurerm_public_ip" "boundary_api_lb" {
  count = var.api_lb_is_internal == false ? 1 : 0

  name                = "${var.friendly_name_prefix}-boundary-api-lb-ip"
  resource_group_name = local.resource_group_name
  location            = var.location
  zones               = var.availability_zones
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = merge(
    { "Name" = "${var.friendly_name_prefix}-boundary-api-lb-ip" },
    var.common_tags
  )
}

resource "azurerm_lb" "boundary_api" {

  name                = "${var.friendly_name_prefix}-boundary-api-lb"
  resource_group_name = local.resource_group_name
  location            = var.location
  sku                 = "Standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name                          = "boundary-frontend-api-${local.api_lb_frontend_name_suffix}"
    zones                         = var.api_lb_is_internal == true ? var.availability_zones : null
    public_ip_address_id          = var.api_lb_is_internal == false ? azurerm_public_ip.boundary_api_lb[0].id : null
    subnet_id                     = var.api_lb_is_internal == true ? var.api_lb_subnet_id : null
    private_ip_address_allocation = var.api_lb_is_internal == true ? "Static" : null
    private_ip_address            = var.api_lb_is_internal == true ? var.api_lb_private_ip : null
  }

  tags = merge(
    { "Name" = "${var.friendly_name_prefix}-boundary-api-lb" },
    var.common_tags
  )
}

resource "azurerm_lb_backend_address_pool" "boundary_api" {

  name            = "${var.friendly_name_prefix}-boundary-api-backend"
  loadbalancer_id = azurerm_lb.boundary_api.id
}

resource "azurerm_lb_probe" "boundary_api" {

  name                = "boundary-api-controller-lb-probe"
  loadbalancer_id     = azurerm_lb.boundary_api.id
  protocol            = "Https"
  port                = 9203
  request_path        = "/health"
  interval_in_seconds = 15
  number_of_probes    = 5
}

resource "azurerm_lb_rule" "boundary_api" {

  name                           = "${var.friendly_name_prefix}-boundary-api-lb-rule-app"
  loadbalancer_id                = azurerm_lb.boundary_api.id
  probe_id                       = azurerm_lb_probe.boundary_api.id
  protocol                       = "Tcp"
  frontend_ip_configuration_name = azurerm_lb.boundary_api.frontend_ip_configuration[0].name
  frontend_port                  = 443
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.boundary_api.id]
  backend_port                   = 9200
}

#------------------------------------------------------------------------------
# Cluster Load Balancer
#------------------------------------------------------------------------------
resource "azurerm_lb" "boundary_cluster" {

  name                = "${var.friendly_name_prefix}-boundary-cluster-lb"
  resource_group_name = local.resource_group_name
  location            = var.location
  sku                 = "Standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name                          = "boundary-frontend-cluster-internal"
    zones                         = var.availability_zones
    subnet_id                     = var.cluster_lb_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.cluster_lb_private_ip
  }

  tags = merge(
    { "Name" = "${var.friendly_name_prefix}-boundary-cluster-lb" },
    var.common_tags
  )
}

resource "azurerm_lb_backend_address_pool" "boundary_cluster" {

  name            = "${var.friendly_name_prefix}-boundary-cluster-backend"
  loadbalancer_id = azurerm_lb.boundary_cluster.id
}

resource "azurerm_lb_probe" "boundary_cluster" {

  name                = "boundary-cluster-controller-lb-probe"
  loadbalancer_id     = azurerm_lb.boundary_cluster.id
  protocol            = "Https"
  port                = 9203
  request_path        = "/health"
  interval_in_seconds = 15
  number_of_probes    = 5
}

resource "azurerm_lb_rule" "boundary_cluster" {

  name                           = "${var.friendly_name_prefix}-boundary-cluster-lb-rule-app"
  loadbalancer_id                = azurerm_lb.boundary_cluster.id
  probe_id                       = azurerm_lb_probe.boundary_cluster.id
  protocol                       = "Tcp"
  frontend_ip_configuration_name = azurerm_lb.boundary_cluster.frontend_ip_configuration[0].name
  frontend_port                  = 9201
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.boundary_cluster.id]
  backend_port                   = 9201
}