# Oracle Cloud Infrastructure Compute Instance Terraform Module

## Introduction

This module provides the initial bootstrapping needed to build a new Compute Instance and other optional services in Oracle Cloud Infrastructure (OCI). This serves as a foundational component in an OCI environment.

In the examples folder, you can find samples for creating a simple instance, an instance with a block volume attached and mounted, and an instance with multiple VNICs attached.

## Solution

A Compute Instance is the core foundation of a compute deployment in OCI. This module provides the ability to create one or more compute instances. 

By using this module, a basic cloud compute instance will be created (for most use-cases, though not all). See the [Compute Best Practices](https://docs.cloud.oracle.com/iaas/Content/Compute/References/bestpracticescompute.htm#two) for recommendations on how to manage instances.

### Prerequisites
This module does not create any dependencies or prerequisites. 

Create the following before using this module: 
  * Required IAM construct to allow for the creation of resources
  * VCNs/Subnets
  * Security List(s)
    * The *network_security* module may be used to create and manage NFS Security Lists.
  * Route Table
    * Often times only a couple of routing policies exist and are created in the *network* module.
  * DHCP Options
    * Often times only a couple of DHCP Options (DNS profiles) exist and are created in the *network* module.


## Getting Started

Several fully-functional examples are provided in the `examples` directory. 

To get started quickly, for the minimum deployment, you can use the following example, adding the values on .tfvars files and main.tf:

```
$ terraform init
$ terraform plan
$ terraform apply
```

This will deploy a Compute Instance using the module defaults (see below for details).

## Accessing the Solution

This is a core service module: you can access the instances using a private key if the instance is public, or through other instances which have access to this instance/subnet.

You may continue to manage the deployed environment using Terraform (best), the OCI CLI, the OCI console (UI), directly via the API, etc.

## Resource-specific inputs

### Compute Instance

| Attribute | Data Type | Required | Default Value | Valid Values | Description |
|---|---|---|---|---|---|
| default\_compartment\_id | string | yes | none | string of the compartment OCID | This is the default OCID that will be used when creating objects (unless overridden for any specific object). This needs to be the OCID of a pre-existing compartment (it will not create the compartment).  |
| ad | number | yes |  If null, first AD of the region | Availability Domains | Availability Domains of a Region. |
| compartment_ocid | string | yes | none | Compartments available for the user| Unique identifier (OCID) of the compartment in which the Compute Instance is created. |
| shape | string | yes | none | Shapes available | The instance shape. |
| is_monitoring_disabled | bool | no |  false | boolean | Specifies whether the agent can gather performance metrics and monitor the instance. |
| subnet_id |string | yes | none | Subnet created | The subnets in which the instance primary VNICs are created. |
| assign_public_ip | string | no | none | boolean | Specifies whether the VNIC should be assigned a public IP address. |
| vnic_defined_tags |  map | no | none| none | Defined Tag. |
| vnic_display_name | string| no | none | none | A user-friendly name for the VNIC. |
| vnic_freeform_tags | map | no | none | none | Free form tag for the VNIC. |
| private_ip | string | no | no | An ip not used within CIDR| Private IP addresses of your choice to assign to the VNICs. |
| skip_source_dest_check | boolean | no | none | boolean value | Specifies whether the source/destination check is disabled on the VNIC. |
| defined_tags | map | no | none | Defined tags | Defined tag for Instance. |
| display_name | string | no | none | Any string | Display name of the compute instance. This parameter is the Key of the Map of instances; in the example below, "Display Name" = inst1. |
| extended_metadata | map | no | none | valid JSON string | Additional metadata key/value pairs provided by the user. |
| fault_domain | string | no | none | valid Fault Domain in an AD | A fault domain is a grouping of hardware and infrastructure within an availability domain. |
| vnic_freeform_tags | map | no | none | none | Free form tag for the Instance. |
| hostname_label | string | no | none | Valid string | The hostname for the VNIC's primary private IP. |
| ipxe_script | string | no | none | Valid script | The iPXE script which initiates the boot process on the compute instance. |
| pv_encr_trans_enabled | bool | none | false | Boolean value | Enables in-transit encryption for the boot volume's paravirtualized attachment. |
| ssh_authorized_keys | list | no | none | A valid public key |	Specify the path to the public SSH keys in the ~/.ssh/authorized_keys file for the default user on the instance. |
| ssh_private_keys | list | no | none | A valid private key | Required parameter when a Block Volume is informed. Specify a path to the private SSH keys in the ~/.ssh/authorized_keys file for the default user on the instance. |
| user_data | string | no | none | Valid commands | User-defined base64-encoded data to be used by Cloud-Init to run custom scripts, or provide a custom Cloud-Init configuration. |
| image_name | string |yes | none | Valid image Name | The instance image name. Required parameter: an image_name or source_id is required to get an image to launch the instance. |
| source_id | string |yes | none | Valid image OCID | The instance image OCID. Required parameter: an image_name or source_id is required to get an image to launch the instance. |
| source_type | string | yes | none | image / bootVolume | The source type for the instance. |
| boot_vol_size_gbs | number | no | none | >50GB | The size of the boot volume in GB. |
| kms_key_id | string | no | none | none | (Applicable when source_type=image.) The OCID of the KMS key to be used as the master encryption key for the boot volume. |
| preserve_boot_volume | boolean | no | false | Boolean values | Specifies whether to delete or preserve the boot volume when the instance is terminated. |
| instance_timeout | string | no | 25m | Minutes | Timeout setting for creating an instance. (Note: large instance types may need larger timeout than the default 25m.) |
|||||||
| sec_vnic | map | no | none | Secondary VNIC info | Map. (List of secondary VNICs you want to attach to the instance.) |
|||||||
| subnet_id | string | yes | no | none | The OCID of the subnet to create the VNIC in. |
| assign_public_ip | bool | no | no | none | Whether the VNIC should be assigned a public IP address. |
| defined_tags | map | no | no | Valid Defined Tag | Defined tags for this resource. Each key is predefined and scoped to a namespace. For more information, see Resource Tags. Example: {"Operations.CostCenter": "42"} |
| vnic_display_name | string | no | none | no | A user-friendly name for the VNIC. |
| freeform_tags | map | no | none | no | Free-form tags for this resource. Each tag is a simple key-value pair with no predefined name, type, or namespace. |
| hostname_label | string | no | none | no | The hostname for the VNIC's primary private IP. Used for DNS. |
| nsg_ids | list(string) | no | none | Valid NSGs| A list of the OCIDs of the network security groups (NSGs) to add the VNIC to. |
| private_ip | string | no | none | Valid private IP within CIDR | A private IP address of your choice to assign to the VNIC. Must be an available IP address within the subnet's CIDR. |
| skip_src_dest_check | bool | no | false | Boolean value | Specifies whether the source/destination check is disabled on the VNIC. |
| instance_id | string | no | no | Instance OCID | The OCID of the instance. |
| display_name | string | no | none | none | A user-friendly name for the attachment. Does not have to be unique, and it cannot be changed. |
| nic_index | number | no | none | 0 | Which physical network interface card (NIC) the VNIC will use. |
|||||||
| mount_blk_vols | boolean | no | false | boolean | If true, mount block volumes informed. |
| block_volumes | list | no | none | none | A list of Block Volumes OCID created that will be attached to the Instance. |
| volume_id | string | no | none | none | Volume OCID. |
| attachment_type | string | no | none | none | Type of Volume Attachment. |
| volume_mount_dir | string | no | none | none | Name of the directory that will be mounted.|
|||||||
| cons_conn_create | boolean | no | false | boolean | If true, create Console connection for the Instance. |
| cons_conn_def_tags | map | no | no | Valid Defined Tag | Defined tags for this resource. Each key is predefined and scoped to a namespace. For more information, see Resource Tags. Example: {"Operations.CostCenter": "42"} |
| cons_conn_free_tags | map | no | none | no | Free-form tags for this resource. Each tag is a simple key-value pair with no predefined name, type, or namespace. |



***Example***

The following  example creates a compute within a subnet and compartment specified, using a display name of "Simple Instance", with shape *`VM.Standard2.1`*. 


```
##############################################
# Instances variable has a list of instances you want create
#   availability_domain is required, but null will assign the first AD of the region to the instance.
#   compartment_id      is required
#   shape               is required
#   subnet_id           is required
#   source_id           is required
#   All other attributes can be null
##############################################
locals {
  instances = {
        inst-simple = {
            ad                          = null                                                                                  #0-AD1, 1-AD2, 3-AD3 RequiredRequired
            compartment_id              = var.default_compartment_id #Required
            shape                       = "VM.Standard2.1"                                                                      #Required
            subnet_id                   = "ocid1.xxxxx"
            
            is_monitoring_disabled      = null
            
            assign_public_ip            = true
            vnic_defined_tags           = null 
            vnic_display_name           = null
            vnic_freeform_tags          = null #{"Environment" = "Development"}
            nsg_ids                     = null #["ocid1.xxxxx"]
            private_ip                  = null
            skip_src_dest_check         = null

            defined_tags                = null 
            extended_metadata           = null
            fault_domain                = null
            freeform_tags               = null 
            hostname_label              = null
            ipxe_script                 = null
            pv_encr_trans_enabled       = null

            ssh_authorized_keys         = ["</path/public key file>"]     #ex: ["/path/public-key.pub"]
            ssh_private_keys            = ["</path/private key file>"]    #ex: ["/path/private-key"]
            user_data                   = null #base64encode(file("bootstrap.sh"))

            // See https://docs.cloud.oracle.com/iaas/images/
            // Oracle-provided image "Oracle-Linux-7.6-2019.06.15-0"
            image_name                  = "Oracle-Linux-7.6-2019.06.15-0"  #Required
            source_id                   = null #"ocid1.image.oc1.eu-frankfurt-1.xxxxxx" #"ocid1.image.oc1.iad.xxxx"  #Required
            source_type                 = null
            boot_vol_size_gbs           = null
            kms_key_id                  = null

            preserve_boot_volume        = null
            instance_timeout            = null
            sec_vnics                   = null #{} #
            mount_blk_vols              = false
            block_volumes               = null
            cons_conn_create            = null
            cons_conn_def_tags          = null
            cons_conn_free_tags         = null

        }, 

  }

  create_compute = true

}
module "oci_instances" {
  source                  = "../../"
  
  default_compartment_id  = var.default_compartment_id

  instances = local.create_compute ? local.instances : null

}
```


## Outputs

This module returns 1 object :

* `instance`: Contains the details about the provisioned Instance


## Notes/Issues

* Note for regions where you don't have multiple ADs, you can leave as null or inform correct AD.
* Note for Image: you can choose "image_name" or "source_id" to inform the image you will use to launch the instance. If you provide both source_id will be used. Image Names provide by OCI are updated often. Make sure you provided an existing image name for the DataCenter the instance will be deployed on. 
* Note Mount Block Volume: the mount is performed only for Oracle Linux OS. At least one private key "ssh_private_keys" is required, when mounting a block volume and a public IP available to the instance and accessible from the internet. There is a limit for # of block volumes of 20, if you need more, please add the partitions in the list (go to main.tf file; dev_partitions  = ["sdb",...,"sdz"])
* If you change certain parameters, TF will try to delete and create, however it doesn't work properly always... when you see errors like the below, use `terraform destroy`, then `terraform apply` (instead of relying on `terraform apply` to handle things correctly).


## URLs

* [https://docs.cloud.oracle.com/iaas/Content/Compute/Concepts/computeoverview.htm](https://docs.cloud.oracle.com/iaas/Content/Compute/Concepts/computeoverview.htm)
* [https://docs.cloud.oracle.com/iaas/Content/Compute/References/bestpracticescompute.htm#two](https://docs.cloud.oracle.com/iaas/Content/Compute/References/bestpracticescompute.htm#two)
* [https://www.terraform.io/docs/providers/oci/r/core_instance.html](https://www.terraform.io/docs/providers/oci/r/core_instance.html)

## Versions

This module has been developed and tested by running terraform on macOS Mojave Version 10.14.5

```
user-mac$ terraform --version
Terraform v0.12.3
+ provider.oci v3.31.0
```

## Contributing

This project is open source. Oracle appreciates any contributions that are made by the open source community.

## License

Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.

Licensed under the Universal Permissive License 1.0.

See [LICENSE](LICENSE) for more details.
