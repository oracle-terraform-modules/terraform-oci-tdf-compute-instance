# Copyright (c) 2020 Oracle and/or its affiliates,  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Network

module "oci_network" {
  source = "https://github.com/oracle-terraform-modules/terraform-oci-tdf-network.git?ref=v0.9.3"
  
  default_compartment_id = var.default_compartment_id

  vcn_options = {
    display_name   = "VCNModule"
    cidr           = "10.0.0.0/16"
    enable_dns     = true
    dns_label      = "simpletest"
    compartment_id = null
    defined_tags   = null
    freeform_tags  = null
  }

  create_igw = true

  route_tables = {
    my_rt = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      route_rules = [
        {
          dst         = "0.0.0.0/0"
          dst_type    = "CIDR_BLOCK"
          next_hop_id = module.oci_network.igw.id
        }
      ]
    }
  }

  dhcp_options = {
    vcn = {
      compartment_id     = null
      server_type        = "VcnLocalPlusInternet"
      forwarder_1_ip     = null
      forwarder_2_ip     = null
      forwarder_3_ip     = null
      search_domain_name = null
    }
  }
}

# Subnet

module "oci_subnets" {
  source = "https://github.com/oracle-terraform-modules/terraform-oci-tdf-subnet.git?ref=v0.9.3"
  

  default_compartment_id = var.default_compartment_id
  vcn_id                 = module.oci_network.vcn.id
  vcn_cidr               = module.oci_network.vcn.cidr_block

  subnets = {
    subnetModule = {
      compartment_id    = var.default_compartment_id
      dynamic_cidr      = false
      cidr              = "10.0.0.0/24"
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "dnslabel"
      private           = false
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.oci_network.route_tables.my_rt.id
      security_list_ids = null
      defined_tags      = null
      freeform_tags     = null
    },
    subnetModule1 = {
      compartment_id    = var.default_compartment_id
      dynamic_cidr      = false
      cidr              = "10.0.1.0/24"
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "dnslabel1"
      private           = false
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.oci_network.route_tables.my_rt.id
      security_list_ids = null
      defined_tags      = null
      freeform_tags     = null
    }

  }
}

# Compute Instance

module "oci_instances" {
  source = "../../"

  default_compartment_id = var.default_compartment_id

  instances = {
    "inst1-vnics" = {
      ad                     = 0                          #0-AD1, 1-AD2, 2-AD3 Required
      compartment_id         = var.default_compartment_id #Required
      shape                  = "VM.Standard1.1"           #Required
      is_monitoring_disabled = null
      subnet_id              = module.oci_subnets.subnets.subnetModule.id
      assign_public_ip       = true
      vnic_defined_tags      = null
      vnic_display_name      = null
      vnic_freeform_tags     = null
      nsg_ids                = null
      private_ip             = null
      skip_src_dest_check    = null

      defined_tags          = { "Team.Owner" = "username@acme.com" }
      display_name          = null
      extended_metadata     = null
      fault_domain          = null
      freeform_tags         = { "Environment" = "Development" }
      hostname_label        = null
      ipxe_script           = null
      pv_encr_trans_enabled = null

      ssh_authorized_keys = ["</path/public key file>"]  #ex: ["/path/public-key.pub"]
      ssh_private_keys    = ["</path/private key file>"] #ex: ["/path/private-key"]

      user_data = null
      // See https://docs.cloud.oracle.com/iaas/images/
      // Oracle-provided image "Oracle-Linux-7.7-2019.10.19-0"
      image_name             = "Oracle-Linux-7.7-2019.10.19-0" #Required
      mkp_image_name         = null
      mkp_image_name_version = null
      source_id              = null # "ocid1.image.oc1.iad.aaaaaaaay66pu7z27ltbx2uuatzgfywzixbp34wx7xoze52pk33psz47vlfa" #Required
      source_type            = null
      boot_vol_size_gbs      = null
      kms_key_id             = null

      preserve_boot_volume = null
      instance_timeout     = null

      sec_vnics = {
        vnic1 = {
          subnet_id = module.oci_subnets.subnets.subnetModule1.id

          #Optional
          assign_public_ip    = null
          defined_tags        = null
          vnic_display_name   = null
          freeform_tags       = null
          hostname_label      = null
          nsg_ids             = null
          private_ip          = null
          skip_src_dest_check = null

          #
          instance_id = null #MMmodule.oci_instances.instance.inst1.id

          #Optional
          display_name = "AttachInst1Vnic2"
          nic_index    = null
        }
      }
      mount_blk_vols      = null
      block_volumes       = null
      cons_conn_create    = null
      cons_conn_def_tags  = null
      cons_conn_free_tags = null
      bastion_ip          = null

    }

    "inst2-vnics" = {
      ad                     = 1                          #0-AD1, 1-AD2, 2-AD3 Required
      compartment_id         = var.default_compartment_id #Required
      shape                  = "VM.Standard1.1"           #Required
      is_monitoring_disabled = null
      subnet_id              = module.oci_subnets.subnets.subnetModule1.id
      assign_public_ip       = true
      vnic_defined_tags      = null
      vnic_display_name      = null
      vnic_freeform_tags     = null
      nsg_ids                = null
      private_ip             = null
      skip_src_dest_check    = null

      defined_tags          = { "Team.Owner" = "username@acme.com" }
      display_name          = null
      extended_metadata     = null
      fault_domain          = null
      freeform_tags         = { "Environment" = "Development" }
      hostname_label        = null
      ipxe_script           = null
      pv_encr_trans_enabled = null

      ssh_authorized_keys = ["</path/public key file>"]  #ex: ["/path/public-key.pub"]
      ssh_private_keys    = ["</path/private key file>"] #ex: ["/path/private-key"]
      user_data           = null

      // See https://docs.cloud.oracle.com/iaas/images/
      image_name             = null                                                                               #"Oracle-Linux-7.6-2019.06.15-0"  #Required
      source_id              = "ocid1.image.oc1.iad.aaaaaaaay66pu7z27ltbx2uuatzgfywzixbp34wx7xoze52pk33psz47vlfa" #Required
      mkp_image_name         = null
      mkp_image_name_version = null
      source_type            = null
      boot_vol_size_gbs      = null
      kms_key_id             = null

      preserve_boot_volume = null
      instance_timeout     = null
      sec_vnics = {
        vnic1 = {
          subnet_id = module.oci_subnets.subnets.subnetModule.id

          #Optional
          assign_public_ip    = null
          defined_tags        = null
          vnic_display_name   = "Inst2Vnic2"
          freeform_tags       = null
          hostname_label      = null
          nsg_ids             = null
          private_ip          = null
          skip_src_dest_check = null

          #
          instance_id = null

          #Optional
          display_name = "AttachInst2Vnic2"
          nic_index    = null
        }
      }
      mount_blk_vols      = null
      block_volumes       = null
      cons_conn_create    = null
      cons_conn_def_tags  = null
      cons_conn_free_tags = null
      bastion_ip          = null
    }

  }

}
