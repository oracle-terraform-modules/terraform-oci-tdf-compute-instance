# Copyright (c) 2020 Oracle and/or its affiliates,  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl.


locals {
  instances = {
    inst-simple = {
      ad             = null                       #0-AD1, 1-AD2, 3-AD3 RequiredRequired
      compartment_id = var.default_compartment_id #Required
      shape          = "VM.Standard2.1"           #Required
      
      subnet_id      = null #"ocid1.xxxxx"

      is_monitoring_disabled = null

      assign_public_ip    = true
      vnic_defined_tags   = null 
      vnic_display_name   = null
      vnic_freeform_tags  = null 
      nsg_ids             = null #["ocid1.xxxxx"]
      private_ip          = null
      skip_src_dest_check = null

      defined_tags          = null 
      extended_metadata     = null
      fault_domain          = null
      freeform_tags         = null 
      hostname_label        = null
      ipxe_script           = null
      pv_encr_trans_enabled = null

      ssh_authorized_keys = ["</path/public key file>"]  #ex: ["/path/public-key.pub"]
      ssh_private_keys    = ["</path/private key file>"] #ex: ["/path/private-key"]
      bastion_ip          = null
      user_data           = null #base64encode(file("bootstrap.sh"))

      // See https://docs.cloud.oracle.com/iaas/images/
      // Oracle-provided image "Oracle-Linux-7.7-2019.10.19-0"
      image_name             = "Oracle-Linux-7.7-2019.10.19-0" #Required
      source_id              = null                            #"ocid1.image.oc1.eu-frankfurt-1.aaaaaaaax3xjmpwufw6tucuoyuenletg74sdsj5f2gzsvlv4mqbbgeokqzsq" #"ocid1.image.oc1.iad.aaaaaaaay66pu7z27ltbx2uuatzgfywzixbp34wx7xoze52pk33psz47vlfa"  #Required
      mkp_image_name         = null
      mkp_image_name_version = null
      source_type            = null
      boot_vol_size_gbs      = null
      kms_key_id             = null

      preserve_boot_volume = null
      instance_timeout     = null
      sec_vnics            = null #{} #
      mount_blk_vols       = false
      block_volumes        = null
      cons_conn_create     = null
      cons_conn_def_tags   = null
      cons_conn_free_tags  = null
    },

  }

  create_compute = true

}
module "oci_instances" {
  source = "../../"

  default_compartment_id = var.default_compartment_id

  instances = local.create_compute ? local.instances : null

}

