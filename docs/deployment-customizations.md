# Deployment Customizations

On this page are various deployment customizations and their corresponding input variables that you may set to meet your requirements.

## Load Balancing

This module creates two Network Load Balancer (NLB) for the Boundary Controller. The first one is used for the API and can either be internal or external. Boundary Clients will use this NLB for communicating the Boundary Controllers. **The default is `internal`**, but the following module boolean input variable may be set to configure the load balancer to be `external` (internet-facing) if desirable.

```hcl
api_lb_is_internal = true
```

The second NLB is used for Cluster communication. This is by default `internal` and is not open to the internet. This is used as the upstream for Boundary Ingress Workers. This load balancer does not need to be `internet-facing` unless there will be Boundary Ingress workers connecting to the Boundary Cluster over the internet and not using a VPN / Express Route, etc. This can be configured by the below variable.

```hcl
cluster_lb_is_internal = true
```

## DNS

If you have an existing Azure DNS zone (public or private) that you would like this module to create a DNS record within for the Boundary FQDN, the following input variables may be set. This is completely optional; you are free to create your own DNS record for the Boundary FQDN resolving to the Boundary load balancer out-of-band from this module.

### Azure Private DNS Zone

If your load balancer is internal (`api_lb_is_internal = true`) and a private, static IP is set (`api_lb_private_ip = "10.0.1.20"`), then the DNS record should be created in a private zone.

```hcl
create_boundary_private_dns_record = true
private_dns_zone_name         = "<example.com>"
private_dns_zone_rg           = "<my-private-dns-zone-resource-group-name>"
```

### Azure Public DNS Zone

If your load balancer is external (`lb_is_internal = false`), the module will automatically create a public IP address for the Boundary load balancer, and hence the DNS record should be created in a public zone.

```hcl
create_boundary_public_dns_record  = true
public_dns_zone_name          = "<example.com>"
public_dns_zone_rg            = "<my-public-dns-zone-resource-group-name>"
```

## Custom VM Image

If a custom VM image is preferred over using a standard marketplace image, the following variables may be set:

```hcl
vm_custom_image_name    = "<my-custom-ubuntu-2204-image>"
vm_custom_image_rg_name = "<my-custom-image-resource-group-name>"
```

## PostgreSQL Customer Managed Key (CMK)

The following variables may be set to configure PostgreSQL Flexible Server with a customer managed key (CMK) for encryption:

```hcl
postgres_cmk_key_vault_id                      = "<key-vault-id-of-boundary-postgres-cmk>"
postgres_cmk_key_vault_key_id                  = "<https://postgres-cmk-identifier>"         # primary region
postgres_geo_backup_key_vault_key_id           = "<https://postgres-cmk-identifier>"         # secondary region
postgres_geo_backup_user_assigned_identity_id = "<user-assigned-msi-id-for-geo-backup-cmk>" # secondary region
```

>📝 Note: `postgres_geo_backup_key_vault_key_id` and `postgres_geo_backup_user_assigned_identity_id` are only needed if `postgres_geo_redundant_backup_enabled` is `true`.

## VM Disk Encryption Set

The following variables may be set to configure an existing Disk Encryption Set for the Boundary VMSS:

```hcl
vm_disk_encryption_set_name = <"my-disk-encryption-set-name">
vm_disk_encryption_set_rg   = <"my-disk-encryption-set-resource-group-name">
```

>📝 Note: ensure that your Key Vault that contains the key for the Disk Encryption Set has an Access Policy that allows the following key permissions: `Get`, `WrapKey`, and `UnwrapKey`.

## Deployment Troubleshooting

In the `compute.tf` there is a commented out local file resource that will render the Boundary custom data script to a local file where this module is being run. This can be useful for reviewing the custom data script as it will be rendered on the deployed VM. This fill will contain sensitive vaults so do not commit this and delete this file when done troubleshooting.

## Boundary Session Recording

Boundary Enterprise and HCP Boundary have support for Session Recording. One of the requirements however is native integration to the object storage, which currently is AWS and Minio, or support native S3 APIs. Boundary Does not have native integration to Azure Blob Storage and Azure Blob storage does not support native S3 APIs. Once either of these has been implemented we will add Boundary Session Recording support to this Module.
