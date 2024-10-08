# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

// This is a placeholder file for the backend configuration.
// When deploying this module in production, you should the AzureRM Blob Storage remote backend.
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "StorageAccount-ResourceGroup"
#     storage_account_name = "abcd1234"
#     container_name       = "tfstate"
#     key                  = "prod.terraform.tfstate"
#   }
# }