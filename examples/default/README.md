<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.101 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_boundary_controller"></a> [boundary\_controller](#module\_boundary\_controller) | ../.. | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boundary_database_password_key_vault_secret_name"></a> [boundary\_database\_password\_key\_vault\_secret\_name](#input\_boundary\_database\_password\_key\_vault\_secret\_name) | Name of the secret in the Key Vault that contains the boundary database password. | `string` | n/a | yes |
| <a name="input_boundary_fqdn"></a> [boundary\_fqdn](#input\_boundary\_fqdn) | Fully qualified domain name of boundary instance. This name should resolve to the load balancer IP address and will be what clients use to access boundary. | `string` | n/a | yes |
| <a name="input_boundary_license_key_vault_secret_id"></a> [boundary\_license\_key\_vault\_secret\_id](#input\_boundary\_license\_key\_vault\_secret\_id) | ID of Key Vault secret containing boundary license. | `string` | n/a | yes |
| <a name="input_boundary_tls_ca_bundle_key_vault_secret_id"></a> [boundary\_tls\_ca\_bundle\_key\_vault\_secret\_id](#input\_boundary\_tls\_ca\_bundle\_key\_vault\_secret\_id) | ID of Key Vault secret containing boundary TLS custom CA bundle. | `string` | n/a | yes |
| <a name="input_boundary_tls_cert_key_vault_secret_id"></a> [boundary\_tls\_cert\_key\_vault\_secret\_id](#input\_boundary\_tls\_cert\_key\_vault\_secret\_id) | ID of Key Vault secret containing boundary TLS certificate. | `string` | n/a | yes |
| <a name="input_boundary_tls_privkey_key_vault_secret_id"></a> [boundary\_tls\_privkey\_key\_vault\_secret\_id](#input\_boundary\_tls\_privkey\_key\_vault\_secret\_id) | ID of Key Vault secret containing boundary TLS private key. | `string` | n/a | yes |
| <a name="input_cluster_lb_private_ip"></a> [cluster\_lb\_private\_ip](#input\_cluster\_lb\_private\_ip) | Private IP address for internal Azure Load Balancer. | `string` | n/a | yes |
| <a name="input_controller_subnet_id"></a> [controller\_subnet\_id](#input\_controller\_subnet\_id) | Subnet ID for controller VMs. | `string` | n/a | yes |
| <a name="input_db_subnet_id"></a> [db\_subnet\_id](#input\_db\_subnet\_id) | Subnet ID for PostgreSQL database. | `string` | n/a | yes |
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | Friendly name prefix for uniquely naming Azure resources. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for this boundary deployment. | `string` | n/a | yes |
| <a name="input_prereqs_key_vault_id"></a> [prereqs\_key\_vault\_id](#input\_prereqs\_key\_vault\_id) | ID of the 'prereqs' Key Vault to use for prereqs boundary deployment. | `string` | n/a | yes |
| <a name="input_prereqs_key_vault_name"></a> [prereqs\_key\_vault\_name](#input\_prereqs\_key\_vault\_name) | Name of the 'prereqs' Key Vault to use for prereqs boundary deployment. | `string` | n/a | yes |
| <a name="input_prereqs_key_vault_rg_name"></a> [prereqs\_key\_vault\_rg\_name](#input\_prereqs\_key\_vault\_rg\_name) | Name of the Resource Group where the 'prereqs' Key Vault resides. | `string` | n/a | yes |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | VNet ID where boundary resources will reside. | `string` | n/a | yes |
| <a name="input_worker_subnet_id"></a> [worker\_subnet\_id](#input\_worker\_subnet\_id) | Subnet ID for worker VMs. | `string` | n/a | yes |
| <a name="input_additional_package_names"></a> [additional\_package\_names](#input\_additional\_package\_names) | List of additional repository package names to install | `set(string)` | `[]` | no |
| <a name="input_api_lb_is_internal"></a> [api\_lb\_is\_internal](#input\_api\_lb\_is\_internal) | Boolean to create an internal or external Azure Load Balancer for boundary. | `bool` | `false` | no |
| <a name="input_api_lb_private_ip"></a> [api\_lb\_private\_ip](#input\_api\_lb\_private\_ip) | Private IP address for internal Azure Load Balancer. Only valid when `lb_is_internal` is `true`. | `string` | `null` | no |
| <a name="input_api_lb_subnet_id"></a> [api\_lb\_subnet\_id](#input\_api\_lb\_subnet\_id) | Subnet ID for Boundary API load balancer. | `string` | `null` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of Azure Availability Zones to spread boundary resources across. | `set(string)` | <pre>[<br/>  "1",<br/>  "2",<br/>  "3"<br/>]</pre> | no |
| <a name="input_boundary_controller_key_vault_name"></a> [boundary\_controller\_key\_vault\_name](#input\_boundary\_controller\_key\_vault\_name) | Name of the existing Azure Key Vault to use for Boundary Controller keys. | `string` | `null` | no |
| <a name="input_boundary_controller_key_vault_rg_name"></a> [boundary\_controller\_key\_vault\_rg\_name](#input\_boundary\_controller\_key\_vault\_rg\_name) | Name of the existing Resource Group containing the Azure Key Vault to use for Boundary Controller keys. | `string` | `null` | no |
| <a name="input_boundary_database_name"></a> [boundary\_database\_name](#input\_boundary\_database\_name) | PostgreSQL database name for boundary. | `string` | `"boundary"` | no |
| <a name="input_boundary_database_paramaters"></a> [boundary\_database\_paramaters](#input\_boundary\_database\_paramaters) | PostgreSQL server parameters for the connection URI. Used to configure the PostgreSQL connection. | `string` | `"sslmode=require"` | no |
| <a name="input_boundary_license_reporting_opt_out"></a> [boundary\_license\_reporting\_opt\_out](#input\_boundary\_license\_reporting\_opt\_out) | Boolean to opt out of license reporting. | `bool` | `false` | no |
| <a name="input_boundary_tls_disable"></a> [boundary\_tls\_disable](#input\_boundary\_tls\_disable) | Boolean to disable TLS for boundary. | `bool` | `false` | no |
| <a name="input_boundary_version"></a> [boundary\_version](#input\_boundary\_version) | Version of Boundary to install. | `string` | `"0.17.1+ent"` | no |
| <a name="input_boundary_worker_key_vault_name"></a> [boundary\_worker\_key\_vault\_name](#input\_boundary\_worker\_key\_vault\_name) | Name of the existing Azure Key Vault to use for Boundary Worker keys. | `string` | `null` | no |
| <a name="input_boundary_worker_key_vault_rg_name"></a> [boundary\_worker\_key\_vault\_rg\_name](#input\_boundary\_worker\_key\_vault\_rg\_name) | Name of the existing Resource Group containing the Azure Key Vault to use for Boundary Worker keys. | `string` | `null` | no |
| <a name="input_cluster_lb_subnet_id"></a> [cluster\_lb\_subnet\_id](#input\_cluster\_lb\_subnet\_id) | Subnet ID for Boundary 1ster load balancer. | `string` | `null` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of common tags for taggable Azure resources. | `map(string)` | `{}` | no |
| <a name="input_create_boundary_controller_key_vault"></a> [create\_boundary\_controller\_key\_vault](#input\_create\_boundary\_controller\_key\_vault) | Boolean to create a Key Vault for Boundary Controller. | `bool` | `true` | no |
| <a name="input_create_boundary_controller_recovery_key"></a> [create\_boundary\_controller\_recovery\_key](#input\_create\_boundary\_controller\_recovery\_key) | Boolean to create a recovery key in the Boundary Controller Key Vault. | `bool` | `true` | no |
| <a name="input_create_boundary_controller_root_key"></a> [create\_boundary\_controller\_root\_key](#input\_create\_boundary\_controller\_root\_key) | Boolean to create a root key in the Boundary Controller Key Vault. | `bool` | `true` | no |
| <a name="input_create_boundary_private_dns_record"></a> [create\_boundary\_private\_dns\_record](#input\_create\_boundary\_private\_dns\_record) | Boolean to create a DNS record for boundary in a private Azure DNS zone. `private_dns_zone_name` must also be provided when `true`. | `bool` | `false` | no |
| <a name="input_create_boundary_public_dns_record"></a> [create\_boundary\_public\_dns\_record](#input\_create\_boundary\_public\_dns\_record) | Boolean to create a DNS record for boundary in a public Azure DNS zone. `public_dns_zone_name` must also be provided when `true`. | `bool` | `false` | no |
| <a name="input_create_boundary_worker_key"></a> [create\_boundary\_worker\_key](#input\_create\_boundary\_worker\_key) | Boolean to create the worker key. | `bool` | `true` | no |
| <a name="input_create_boundary_worker_key_vault"></a> [create\_boundary\_worker\_key\_vault](#input\_create\_boundary\_worker\_key\_vault) | Boolean to create a Key Vault for Boundary Worker. | `bool` | `true` | no |
| <a name="input_create_postgres_private_endpoint"></a> [create\_postgres\_private\_endpoint](#input\_create\_postgres\_private\_endpoint) | Boolean to create a private endpoint and private DNS zone for PostgreSQL Flexible Server. | `bool` | `true` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Boolean to create a new Resource Group for this boundary deployment. | `bool` | `true` | no |
| <a name="input_is_govcloud_region"></a> [is\_govcloud\_region](#input\_is\_govcloud\_region) | Boolean indicating whether this boundary deployment is in an Azure Government Cloud region. | `bool` | `false` | no |
| <a name="input_key_vault_cidr_allow_list"></a> [key\_vault\_cidr\_allow\_list](#input\_key\_vault\_cidr\_allow\_list) | List of CIDR blocks to allow access to the Key Vault. This should be the public IP address of the machine running the Terraform deployment. | `list(string)` | `[]` | no |
| <a name="input_postgres_administrator_login"></a> [postgres\_administrator\_login](#input\_postgres\_administrator\_login) | Username for administrator login of PostreSQL database. | `string` | `"boundary"` | no |
| <a name="input_postgres_backup_retention_days"></a> [postgres\_backup\_retention\_days](#input\_postgres\_backup\_retention\_days) | Number of days to retain backups of PostgreSQL Flexible Server. | `number` | `35` | no |
| <a name="input_postgres_cmk_key_vault_id"></a> [postgres\_cmk\_key\_vault\_id](#input\_postgres\_cmk\_key\_vault\_id) | ID of the Key Vault containing the customer-managed key (CMK) for encrypting the PostgreSQL Flexible Server database. | `string` | `null` | no |
| <a name="input_postgres_cmk_key_vault_key_id"></a> [postgres\_cmk\_key\_vault\_key\_id](#input\_postgres\_cmk\_key\_vault\_key\_id) | ID of the Key Vault key to use for customer-managed key (CMK) encryption of PostgreSQL Flexible Server database. | `string` | `null` | no |
| <a name="input_postgres_create_mode"></a> [postgres\_create\_mode](#input\_postgres\_create\_mode) | Determines if the PostgreSQL Flexible Server is being created as a new server or as a replica. | `string` | `"Default"` | no |
| <a name="input_postgres_enable_high_availability"></a> [postgres\_enable\_high\_availability](#input\_postgres\_enable\_high\_availability) | Boolean to enable `ZoneRedundant` high availability with PostgreSQL database. | `bool` | `false` | no |
| <a name="input_postgres_geo_backup_key_vault_key_id"></a> [postgres\_geo\_backup\_key\_vault\_key\_id](#input\_postgres\_geo\_backup\_key\_vault\_key\_id) | ID of the Key Vault key to use for customer-managed key (CMK) encryption of PostgreSQL Flexible Server geo-redundant backups. This key must be in the same region as the geo-redundant backup. | `string` | `null` | no |
| <a name="input_postgres_geo_backup_user_assigned_identity_id"></a> [postgres\_geo\_backup\_user\_assigned\_identity\_id](#input\_postgres\_geo\_backup\_user\_assigned\_identity\_id) | ID of the User-Assigned Identity to use for customer-managed key (CMK) encryption of PostgreSQL Flexible Server geo-redundant backups. This identity must have 'Get', 'WrapKey', and 'UnwrapKey' permissions to the Key Vault. | `string` | `null` | no |
| <a name="input_postgres_geo_redundant_backup_enabled"></a> [postgres\_geo\_redundant\_backup\_enabled](#input\_postgres\_geo\_redundant\_backup\_enabled) | Boolean to enable PostreSQL geo-redundant backup configuration in paired Azure region. | `bool` | `true` | no |
| <a name="input_postgres_maintenance_window"></a> [postgres\_maintenance\_window](#input\_postgres\_maintenance\_window) | Map of maintenance window settings for PostgreSQL Flexible Server. | `map(number)` | <pre>{<br/>  "day_of_week": 0,<br/>  "start_hour": 0,<br/>  "start_minute": 0<br/>}</pre> | no |
| <a name="input_postgres_primary_availability_zone"></a> [postgres\_primary\_availability\_zone](#input\_postgres\_primary\_availability\_zone) | Number for the availability zone for the primary PostgreSQL Flexible Server instance to reside in. | `number` | `1` | no |
| <a name="input_postgres_secondary_availability_zone"></a> [postgres\_secondary\_availability\_zone](#input\_postgres\_secondary\_availability\_zone) | Number for the availability zone for the standby PostgreSQL Flexible Server instance to reside in. | `number` | `2` | no |
| <a name="input_postgres_sku"></a> [postgres\_sku](#input\_postgres\_sku) | PostgreSQL database SKU. | `string` | `"GP_Standard_D4ds_v4"` | no |
| <a name="input_postgres_source_server_id"></a> [postgres\_source\_server\_id](#input\_postgres\_source\_server\_id) | ID of the source PostgreSQL Flexible Server to replicate from. Only valid when `is_secondary_region` is `true` and `postgres_create_mode` is `Replica`. | `string` | `null` | no |
| <a name="input_postgres_storage_mb"></a> [postgres\_storage\_mb](#input\_postgres\_storage\_mb) | Storage capacity of PostgreSQL Flexible Server (unit is megabytes). | `number` | `65536` | no |
| <a name="input_postgres_version"></a> [postgres\_version](#input\_postgres\_version) | PostgreSQL database version. | `number` | `16` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Name of existing private Azure DNS zone to create DNS record in. Required when `create_boundary_private_dns_record` is `true`. | `string` | `null` | no |
| <a name="input_private_dns_zone_rg"></a> [private\_dns\_zone\_rg](#input\_private\_dns\_zone\_rg) | Name of Resource Group where `private_dns_zone_name` resides. Required when `create_boundary_private_dns_record` is `true`. | `string` | `null` | no |
| <a name="input_public_dns_zone_name"></a> [public\_dns\_zone\_name](#input\_public\_dns\_zone\_name) | Name of existing public Azure DNS zone to create DNS record in. Required when `create_boundary_public_dns_record` is `true`. | `string` | `null` | no |
| <a name="input_public_dns_zone_rg"></a> [public\_dns\_zone\_rg](#input\_public\_dns\_zone\_rg) | Name of Resource Group where `public_dns_zone_name` resides. Required when `create_boundary_public_dns_record` is `true`. | `string` | `null` | no |
| <a name="input_recovery_key_name"></a> [recovery\_key\_name](#input\_recovery\_key\_name) | Name of the existing recovery key in the Boundary Controller Key Vault. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of Resource Group to create. | `string` | `"boundary-controller-rg"` | no |
| <a name="input_root_key_name"></a> [root\_key\_name](#input\_root\_key\_name) | Name of the existing root key in the Boundary Controller Key Vault. | `string` | `null` | no |
| <a name="input_vm_admin_username"></a> [vm\_admin\_username](#input\_vm\_admin\_username) | Admin username for VMs in VMSS. | `string` | `"boundaryadmin"` | no |
| <a name="input_vm_custom_image_name"></a> [vm\_custom\_image\_name](#input\_vm\_custom\_image\_name) | Name of custom VM image to use for VMSS. If not using a custom image, leave this blank. | `string` | `null` | no |
| <a name="input_vm_custom_image_rg_name"></a> [vm\_custom\_image\_rg\_name](#input\_vm\_custom\_image\_rg\_name) | Resource Group name where the custom VM image resides. Only valid if `vm_custom_image_name` is not null. | `string` | `null` | no |
| <a name="input_vm_disk_encryption_set_name"></a> [vm\_disk\_encryption\_set\_name](#input\_vm\_disk\_encryption\_set\_name) | Name of the Disk Encryption Set to use for VMSS. | `string` | `null` | no |
| <a name="input_vm_disk_encryption_set_rg"></a> [vm\_disk\_encryption\_set\_rg](#input\_vm\_disk\_encryption\_set\_rg) | Name of the Resource Group where the Disk Encryption Set to use for VMSS exists. | `string` | `null` | no |
| <a name="input_vm_enable_boot_diagnostics"></a> [vm\_enable\_boot\_diagnostics](#input\_vm\_enable\_boot\_diagnostics) | Boolean to enable boot diagnostics for VMSS. | `bool` | `false` | no |
| <a name="input_vm_image_offer"></a> [vm\_image\_offer](#input\_vm\_image\_offer) | Offer of the VM image. | `string` | `"0001-com-ubuntu-server-jammy"` | no |
| <a name="input_vm_image_publisher"></a> [vm\_image\_publisher](#input\_vm\_image\_publisher) | Publisher of the VM image. | `string` | `"Canonical"` | no |
| <a name="input_vm_image_sku"></a> [vm\_image\_sku](#input\_vm\_image\_sku) | SKU of the VM image. | `string` | `"22_04-lts-gen2"` | no |
| <a name="input_vm_image_version"></a> [vm\_image\_version](#input\_vm\_image\_version) | Version of the VM image. | `string` | `"latest"` | no |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | SKU for VM size for the VMSS. | `string` | `"Standard_D2s_v5"` | no |
| <a name="input_vm_ssh_public_key"></a> [vm\_ssh\_public\_key](#input\_vm\_ssh\_public\_key) | SSH public key for VMs in VMSS. | `string` | `null` | no |
| <a name="input_vmss_availability_zones"></a> [vmss\_availability\_zones](#input\_vmss\_availability\_zones) | List of Azure Availability Zones to spread the VMSS VM resources across. | `set(string)` | <pre>[<br/>  "1",<br/>  "2",<br/>  "3"<br/>]</pre> | no |
| <a name="input_vmss_vm_count"></a> [vmss\_vm\_count](#input\_vmss\_vm\_count) | Number of VM instances in the VMSS. | `number` | `1` | no |
| <a name="input_worker_key_name"></a> [worker\_key\_name](#input\_worker\_key\_name) | Name of the existing worker key in the Boundary Worker Key Vault. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_boundary_controller_cluster_lb_private_ip"></a> [boundary\_controller\_cluster\_lb\_private\_ip](#output\_boundary\_controller\_cluster\_lb\_private\_ip) | Private IP address of the Boundary Cluster Load Balancer. |
| <a name="output_boundary_database_host"></a> [boundary\_database\_host](#output\_boundary\_database\_host) | FQDN and port of PostgreSQL Flexible Server. |
| <a name="output_boundary_database_name"></a> [boundary\_database\_name](#output\_boundary\_database\_name) | Name of PostgreSQL Flexible Server database. |
| <a name="output_created_boundary_controller_key_vault_name"></a> [created\_boundary\_controller\_key\_vault\_name](#output\_created\_boundary\_controller\_key\_vault\_name) | Name of the Boundary Controller Key Vault. |
| <a name="output_created_boundary_recovery_key_name"></a> [created\_boundary\_recovery\_key\_name](#output\_created\_boundary\_recovery\_key\_name) | Name of the created Boundary Recovery Key. |
| <a name="output_created_boundary_root_key_name"></a> [created\_boundary\_root\_key\_name](#output\_created\_boundary\_root\_key\_name) | Name of the created Boundary Root Key. |
| <a name="output_created_boundary_worker_key_name"></a> [created\_boundary\_worker\_key\_name](#output\_created\_boundary\_worker\_key\_name) | Name of the created Boundary Worker Key. |
| <a name="output_created_boundary_worker_key_vault_name"></a> [created\_boundary\_worker\_key\_vault\_name](#output\_created\_boundary\_worker\_key\_vault\_name) | Name of the Boundary Worker Key Vault. |
| <a name="output_provided_boundary_controller_key_vault_name"></a> [provided\_boundary\_controller\_key\_vault\_name](#output\_provided\_boundary\_controller\_key\_vault\_name) | Name of the provided Boundary Controller Key Vault. |
| <a name="output_provided_boundary_recovery_key_name"></a> [provided\_boundary\_recovery\_key\_name](#output\_provided\_boundary\_recovery\_key\_name) | Name of the provided Boundary Recovery Key. |
| <a name="output_provided_boundary_root_key_name"></a> [provided\_boundary\_root\_key\_name](#output\_provided\_boundary\_root\_key\_name) | Name of the provided Boundary Root Key. |
| <a name="output_provided_boundary_worker_key_name"></a> [provided\_boundary\_worker\_key\_name](#output\_provided\_boundary\_worker\_key\_name) | Name of the provided Boundary Worker Key. |
| <a name="output_provided_boundary_worker_key_vault_name"></a> [provided\_boundary\_worker\_key\_vault\_name](#output\_provided\_boundary\_worker\_key\_vault\_name) | Name of the provided Boundary Worker Key Vault. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the Resource Group. |
| <a name="output_url"></a> [url](#output\_url) | URL of Boundary Controller based on `boundary_fqdn` input. |
<!-- END_TF_DOCS -->