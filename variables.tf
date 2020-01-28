# Copyright (c) 2020 Oracle and/or its affiliates,  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Global variables

variable "default_compartment_id" {
  type        = string
  description = "The default compartment OCID to use for resources (unless otherwise specified)."
}

# Instance variables
variable "instances" {
  type = map(object({
    ad             = number,
    compartment_id = string,
    shape          = string,

    is_monitoring_disabled = bool,

    subnet_id           = string,
    assign_public_ip    = bool,
    vnic_defined_tags   = map(string),
    vnic_display_name   = string,
    vnic_freeform_tags  = map(string),
    nsg_ids             = list(string),
    private_ip          = string,
    skip_src_dest_check = bool,

    defined_tags          = map(string),
    extended_metadata     = map(string),
    fault_domain          = string,
    freeform_tags         = map(string),
    hostname_label        = string,
    ipxe_script           = string,
    pv_encr_trans_enabled = bool,

    ssh_authorized_keys    = list(string),
    ssh_private_keys       = list(string),
    bastion_ip             = string,
    user_data              = string,
    image_name             = string,
    mkp_image_name         = string,
    mkp_image_name_version = string,
    source_id              = string,
    source_type            = string,
    boot_vol_size_gbs      = number,
    kms_key_id             = string,

    preserve_boot_volume = bool,
    instance_timeout     = string,

    sec_vnics = map(object({
      #Required
      subnet_id = string,

      #Optional
      assign_public_ip    = bool,
      defined_tags        = map(string),
      vnic_display_name   = string,
      freeform_tags       = map(string),
      hostname_label      = string,
      nsg_ids             = list(string),
      private_ip          = string,
      skip_src_dest_check = bool,

      #Required
      instance_id = string,

      #Optional
      display_name = string,
      nic_index    = number
    })),

    mount_blk_vols = bool
    block_volumes = list(object({
      volume_id        = string,
      attachment_type  = string,
      volume_mount_dir = string
    })),
    cons_conn_create    = bool,
    cons_conn_def_tags  = map(string),
    cons_conn_free_tags = map(string),

  }))

  description = "Parameters for each instance to be created/managed."

  default = null
  /*
  {
    ad                                  = null,
    compartment_id                      = null,
    shape                               = null,

    is_monitoring_disabled              = null,

    subnet_id                           = null,
    assign_public_ip                    = null,
    vnic_defined_tags                   = null,
    vnic_display_name                   = null,
    vnic_freeform_tags                  = null,
    nsg_ids                             = null,
    private_ip                          = null,
    skip_src_dest_check                 = null,

    defined_tags                        = null,
    extended_metadata                   = null,
    fault_domain                        = null,
    freeform_tags                       = null,
    hostname_label                      = null,
    ipxe_script                         = null, 
    pv_encr_trans_enabled               = null,

    ssh_authorized_keys                 = null,
    ssh_private_keys                    = null,
    user_data                           = null,

    image_name                          = null,
    source_id                           = null,
    source_type                         = null,
    boot_vol_size_gbs                   = null,
    kms_key_id                          = null,

    preserve_boot_volume                = null,
    instance_timeout                    = null,

    sec_vnics                           = null,

    mount_blk_vols                      = null,
    block_volumes                       = null,

    cons_conn_create                    = null,
    cons_conn_def_tags                  = null,
    cons_conn_free_tags                 = null
  }
*/
}

