# Boundary Version Upgrades

See the [Boundary Releases](https://developer.hashicorp.com/boundary/docs/release-notes) page for full details on the releases. Because we have bootstrapped and automated the Boundary deployment, and our Boundary application data is decoupled from the VM(s), the VMs are stateless, ephemeral, and are treated as _immutable_. Therefore, the process of upgrading to a new Boundary version involves replacing/re-imaging the VMs within the Boundary Virtual Machine Scaleset (VMSS), rather than modifying the running VMs in-place. In other words, an upgrade effectively is a re-install of Boundary.

## Upgrade Procedure

This module includes an input variable named `boundary_version` that dictates which version of Boundary is deployed. Here are the steps to follow:

1. Determine your desired version of Boundary from the [Boundary Release Notes](https://developer.hashicorp.com/boundary/docs/release-notes) page. The value that you need will be in the **Version** column of the table that is displayed, and `+ent`

2. Update the value of the `boundary_version` input variable within your `terraform.tfvars` file, and update `vmss_vm_count` to `1`

   ```hcl
   boundary_version = "0.17.1+ent"
    ```

3. Out of precaution, generate a backup of your Azure PostgreSQL Flexible Server Boundary database.

4. During a maintenance window, run `terraform apply` against your root Boundary Controller configuration that manages your Boundary Controller deployment.

6. This will scale down the VMSS to a single instance and trigger it to be re-imaged with the latest changes from the custom data. Monitor the cloud-init processes to ensure a successful re-install.

7. After the Boundary service has started, it may fail requiring a database migration. To perform the migration, on the controller run this command `boundary database migrate -config /etc/boundary.d/controller.hcl`. This will perform the database migration and the Boundary service can be started.

8. Update the value of the `vmss_vm_count` input variable within your `terraform.tfvars` file to the previous value.

9. From within the directory managing your Boundary deployment, run `terraform apply` to scale out the deployment.

9.  Ensure that the VM(s) within the Boundary controller VMSS have been replaced/re-imaged with the changes. Monitor the cloud-init processes to ensure a successful re-install.
