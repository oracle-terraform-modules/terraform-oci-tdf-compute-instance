# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Compute Instance

# default values
locals {
  instance_defaults = {
    ad             = 0,
    compartment_id = null,
    shape          = null,

    is_monitoring_disabled = null,

    subnet_id           = null,
    assign_public_ip    = false,
    vnic_display_name   = null,
    nsg_ids             = null, #[],
    private_ip          = null,
    skip_src_dest_check = null,

    display_name          = "unamed instance",
    extended_metadata     = null,
    fault_domain          = null,
    hostname_label        = null,
    ipxe_script           = null,
    pv_encr_trans_enabled = null,

    ssh_authorized_keys = [],
    user_data           = null,

    image_name             = null,
    source_id              = null,
    source_type            = "image",
    mkp_image_name         = null,
    mkp_image_name_version = null
    boot_vol_size_gbs      = null,
    kms_key_id             = null,

    preserve_boot_volume = false,

    instance_timeout = "25m",

    sec_vnics     = null, #{}
    block_volumes = null, #[]

    cons_conn_create    = false,
    cons_conn_def_tags  = null,
    cons_conn_free_tags = null,


  }

  vnic_defaults = {
    #Required
    subnet_id = null

    #Optional
    assign_public_ip    = false
    vnic_display_name   = null
    hostname_label      = null
    nsg_ids             = []
    private_ip          = null
    skip_src_dest_check = null

    #Required
    instance_id = null

    #Optional
    display_name = null
    nic_index    = null
  }

  block_volume_defaults = {
    attachment_type        = null
    default_compartment_id = null
    instance_id            = null
    volume_id              = null
    public_ip              = null
  }

  def_tags_default  = null
  free_tags_default = null

  instances_keys = keys(var.instances != null ? var.instances : {})

  # List of compute instance by display_name
  comp_inst = { for i in oci_core_instance.this :
    i.display_name =>
    { instance_id    = i.id,
      compartment_id = i.compartment_id,
      public_ip      = i.public_ip,
      private_ip     = i.private_ip,
      bastion_ip     = var.instances[i.display_name].bastion_ip
    }
  }

  # List of compute instance by instance_id
  comp_inst_by_id = { for i in oci_core_instance.this :
    i.id =>
    { instance_id    = i.id,
      compartment_id = i.compartment_id,
      public_ip      = i.public_ip
      display_name   = i.display_name
      private_ip     = i.private_ip
      bastion_ip     = var.instances[i.display_name].bastion_ip
    }
  }

  # list of instances with marketplace images
  mkp_instances = {
    for inst_key, inst_value in var.instances : inst_key => inst_value if inst_value.mkp_image_name != null
  }

  # List of Secondary VNICs
  sec_vnics = flatten([for k, v in(var.instances == null ? {} : var.instances) :
    [for k2, v2 in(var.instances == null ? {} : (var.instances[k].sec_vnics != null ? var.instances[k].sec_vnics : {})) :
      { id                  = k,
        vnic_key            = k2,
        subnet_id           = v2.subnet_id,
        assign_public_ip    = v2.assign_public_ip,
        defined_tags        = v2.defined_tags,
        vnic_display_name   = v2.vnic_display_name,
        freeform_tags       = v2.freeform_tags,
        hostname_label      = v2.hostname_label,
        nsg_ids             = v2.nsg_ids,
        private_ip          = v2.private_ip,
        skip_src_dest_check = v2.skip_src_dest_check,
        display_name        = k,
        nic_index           = v2.nic_index
      }
    ]
  ])

  # Volumes to be attached
  blk_vnics_att = { for x in local.sec_vnics :
    "${x.id}-${x.vnic_key}" => x
  }

  # Used to attach volume to instance
  blk_vols = flatten([for k, v in(var.instances == null ? {} : var.instances) :
    [for v2 in(var.instances == null ? [] : (var.instances[k].block_volumes != null ? var.instances[k].block_volumes : [])) :
      { id               = k,
        volume_id        = v2.volume_id,
        attachment_type  = v2.attachment_type,
        volume_mount_dir = v2.volume_mount_dir,
        dev_partition    = element(local.dev_partitions, index(v.block_volumes[*].volume_id, v2.volume_id)),
        ssh_private_keys = v.ssh_private_keys,
        mount_blk_vols   = v.mount_blk_vols,
        operating_system = v.source_id != null ? (v.mkp_image_name == null ? local.list_images_key[v.source_id].operating_system : null) : (v.image_name != null ? local.list_images[v.image_name].operating_system : null)
      }
    ]
  ])
  # total number of block volumes to attach
  blk_vols_count = length(flatten([for e in [for i in var.instances : length(i.block_volumes != null ? i.block_volumes : [])] : range(e)]))
  # Volumes to be attached
  blk_vols_att = { for x in local.blk_vols :
    x.volume_id => x
  }
  blk_vols_att_list = [for x in local.blk_vols : x]

  # Attach and mount linux volume
  blk_vols_count_linux = length(flatten([for e in [for i in var.instances : length(i.block_volumes != null ? i.block_volumes : []) if(i.source_id != null ? (i.mkp_image_name == null ? local.list_images_key[i.source_id].operating_system : null) : (i.image_name != null ? local.list_images[i.image_name].operating_system : null)) == "Oracle Linux"] : range(e)]))


  # Attach and mount linux volume
  blk_vols_att_linux = { for x in local.blk_vols :
    x.volume_id => x if x.operating_system == "Oracle Linux"
  }

  blk_vols_att_linux_list = [for x in local.blk_vols : x if x.operating_system == "Oracle Linux"]

  # Volume attachment information by volume_id
  blk_vols_att_vol_id = { for x in oci_core_volume_attachment.this :
    x.volume_id => x if x.state == "ATTACHED"
  }

  #  blk_vols_dett_vol_id = [ for x in oci_core_volume_attachment.this :
  #                            x if x.state != "ATTACHED"
  #  ]

  # List of Compute Instance Console connection
  comp_inst_console = [for k, v in(var.instances == null ? {} : var.instances) :
    { id                  = k,
      ssh_authorized_keys = v.ssh_authorized_keys,
      cons_conn_def_tags  = v.cons_conn_def_tags
      cons_conn_free_tags = v.cons_conn_free_tags
    } if v.cons_conn_create == true && v.cons_conn_create != null
  ]

  #20 partitions, if need more add at the end of the list
  dev_partitions = ["sdb", "sdc", "sdd", "sde", "sdf", "sdg", "sdh", "sdi", "sdj", "sdk", "sdl", "sdm", "sdn", "sdo", "sdp", "sdq", "sdr", "sds", "sdt", "sdu"]

  #Transform the list of images in a tuple
  list_images = { for s in data.oci_core_images.this.images :
    s.display_name =>
    { id               = s.id,
      operating_system = s.operating_system
  } }

  # Image list by key to take the OS
  list_images_key = { for s in data.oci_core_images.this.images :
    s.id =>
    { id               = s.id,
      operating_system = s.operating_system
  } }

}

resource "oci_core_instance" "this" {
  for_each = var.instances == null ? {} : var.instances

  #    count = length(local.instances_keys) > 0 ? length(local.instances_keys) : 0

  availability_domain = each.value.ad != null ? lookup(data.oci_identity_availability_domains.this.availability_domains[each.value.ad], "name") : lookup(data.oci_identity_availability_domains.this.availability_domains[local.instance_defaults.ad], "name")
  compartment_id      = each.value.compartment_id != null ? each.value.compartment_id : var.default_compartment_id
  shape               = each.value.shape != null ? each.value.shape : local.instance_defaults.shape

  agent_config {
    is_monitoring_disabled = each.value.is_monitoring_disabled != null ? each.value.is_monitoring_disabled : local.instance_defaults.is_monitoring_disabled
  }

  create_vnic_details {
    subnet_id              = each.value.subnet_id != null ? each.value.subnet_id : local.instance_defaults.subnet_id
    assign_public_ip       = each.value.assign_public_ip != null ? each.value.assign_public_ip : local.instance_defaults.assign_public_ip
    defined_tags           = each.value.vnic_defined_tags != null ? each.value.vnic_defined_tags : local.def_tags_default
    display_name           = each.value.vnic_display_name != null ? each.value.vnic_display_name : local.instance_defaults.vnic_display_name
    freeform_tags          = each.value.vnic_freeform_tags != null ? each.value.vnic_freeform_tags : local.free_tags_default
    nsg_ids                = each.value.nsg_ids != null ? each.value.nsg_ids : local.instance_defaults.nsg_ids
    private_ip             = each.value.private_ip != null ? each.value.private_ip : local.instance_defaults.private_ip
    skip_source_dest_check = each.value.skip_src_dest_check != null ? each.value.skip_src_dest_check : local.instance_defaults.skip_src_dest_check
  }

  defined_tags                        = each.value.defined_tags != null ? each.value.defined_tags : local.def_tags_default
  display_name                        = each.key != null ? each.key : "${local.instance_defaults.display_name}"
  fault_domain                        = each.value.fault_domain != null ? each.value.fault_domain : local.instance_defaults.fault_domain
  freeform_tags                       = each.value.freeform_tags != null ? each.value.freeform_tags : local.free_tags_default
  hostname_label                      = each.value.hostname_label != null ? each.value.hostname_label : local.instance_defaults.hostname_label
  ipxe_script                         = each.value.ipxe_script != null ? each.value.ipxe_script : local.instance_defaults.ipxe_script
  is_pv_encryption_in_transit_enabled = each.value.pv_encr_trans_enabled != null ? each.value.pv_encr_trans_enabled : local.instance_defaults.pv_encr_trans_enabled

  metadata = {
    ssh_authorized_keys = each.value.ssh_authorized_keys != null ? join("\n", [for s in each.value.ssh_authorized_keys : chomp(file(s))]) : chomp(file(local.instance_defaults.ssh_authorized_keys))
    #      user_data               = each.value.user_data != null ? base64encode(file(each.value.user_data)) : local.instance_defaults.user_data
    user_data = each.value.user_data != null ? each.value.user_data : local.instance_defaults.user_data
  }

  source_details {
    source_id               = each.value.source_id != null ? each.value.source_id : each.value.image_name != null ? local.list_images[each.value.image_name].id : local.mkp_image_details[each.key] != null ? local.mkp_image_details[each.key].mkp_image_ocid : local.instance_defaults.source_id
    source_type             = each.value.source_type != null ? each.value.source_type : local.instance_defaults.source_type
    boot_volume_size_in_gbs = each.value.boot_vol_size_gbs != null ? each.value.boot_vol_size_gbs : local.instance_defaults.boot_vol_size_gbs
    kms_key_id              = each.value.kms_key_id != null ? each.value.kms_key_id : local.instance_defaults.kms_key_id
  }

  preserve_boot_volume = each.value.preserve_boot_volume != null ? each.value.preserve_boot_volume : local.instance_defaults.preserve_boot_volume

  timeouts {
    create = each.value.instance_timeout != null ? each.value.instance_timeout : local.instance_defaults.instance_timeout
  }
  depends_on = [oci_marketplace_accepted_agreement.accepted_agreements]
}

# Secondary VNICS

resource "oci_core_vnic_attachment" "this" {
  #  count       = length(local.sec_vnics) > 0 && local.sec_vnics != null ? length(local.sec_vnics) : 0
  for_each   = var.instances == null ? {} : local.blk_vnics_att
  depends_on = [oci_core_instance.this]

  #Optional
  create_vnic_details {

    subnet_id              = each.value.subnet_id != null ? each.value.subnet_id : local.vnic_defaults.subnet_id
    assign_public_ip       = each.value.assign_public_ip != null ? each.value.assign_public_ip : local.vnic_defaults.assign_public_ip
    defined_tags           = each.value.defined_tags != null ? each.value.defined_tags : local.def_tags_default
    display_name           = each.value.vnic_display_name != null ? each.value.vnic_display_name : local.vnic_defaults.vnic_display_name
    freeform_tags          = each.value.freeform_tags != null ? each.value.freeform_tags : local.free_tags_default
    hostname_label         = each.value.hostname_label != null ? each.value.hostname_label : local.vnic_defaults.hostname_label
    nsg_ids                = each.value.nsg_ids != null ? each.value.nsg_ids : local.vnic_defaults.nsg_ids
    private_ip             = each.value.private_ip != null ? each.value.private_ip : local.vnic_defaults.private_ip
    skip_source_dest_check = each.value.skip_src_dest_check != null ? each.value.skip_src_dest_check : local.vnic_defaults.skip_src_dest_check
  }

  #Required
  instance_id = local.comp_inst[each.value.id].instance_id != null ? local.comp_inst[each.value.id].instance_id : local.vnic_defaults.instance_id

  #Optional
  display_name = each.value.display_name != null ? each.value.display_name : each.value.vnic_key
  nic_index    = each.value.nic_index != null ? each.value.nic_index : local.vnic_defaults.nic_index

}

resource "oci_core_volume_attachment" "this" {
  count      = local.blk_vols_count
  depends_on = [oci_core_instance.this]

  attachment_type = local.blk_vols_att_list[count.index].attachment_type != null ? local.blk_vols_att_list[count.index].attachment_type : local.block_volume_defaults.attachment_type
  instance_id     = local.comp_inst[local.blk_vols_att_list[count.index].id].instance_id != null ? local.comp_inst[local.blk_vols_att_list[count.index].id].instance_id : local.block_volume_defaults.instance_id
  volume_id       = local.blk_vols_att_list[count.index].volume_id != null ? local.blk_vols_att_list[count.index].volume_id : local.block_volume_defaults.volume_id

}

resource "null_resource" "mount_blk_vol_linux" {
  triggers = {
    mount  = var.instances == null ? null : length(local.blk_vols_att_linux)
    mountq = var.instances == null ? null : join(",", [for k, v in var.instances : v.mount_blk_vols == null ? false : v.mount_blk_vols])
  }
  count      = local.blk_vols_count_linux
  depends_on = [oci_core_volume_attachment.this]

  connection {
    bastion_host        = local.comp_inst[local.blk_vols_att_linux_list[count.index].id].bastion_ip != null ? local.comp_inst[local.blk_vols_att_linux_list[count.index].id].bastion_ip : null
    bastion_private_key = local.comp_inst[local.blk_vols_att_linux_list[count.index].id].bastion_ip != null ? chomp(file(local.blk_vols_att_linux_list[count.index].ssh_private_keys[0])) : null
    bastion_user        = local.comp_inst[local.blk_vols_att_linux_list[count.index].id].bastion_ip != null ? "opc" : null
    user                = "opc"
    agent               = false
    private_key         = chomp(file(local.blk_vols_att_linux_list[count.index].ssh_private_keys[0]))
    timeout             = "10m"
    host                = local.comp_inst[local.blk_vols_att_linux_list[count.index].id].bastion_ip != null ? (local.comp_inst[local.blk_vols_att_linux_list[count.index].id].private_ip != null ? local.comp_inst[local.blk_vols_att_linux_list[count.index].id].private_ip : local.block_volume_defaults.private_ip) : (local.comp_inst[local.blk_vols_att_linux_list[count.index].id].public_ip != null ? local.comp_inst[local.blk_vols_att_linux_list[count.index].id].public_ip : local.block_volume_defaults.public_ip)
  }
  provisioner "remote-exec" {
    inline = local.blk_vols_att_linux_list[count.index].mount_blk_vols == true ? [
      "if mountpoint -q -- \"${local.blk_vols_att_linux_list[count.index].volume_mount_dir}\" ; ",
      " then ",
      "echo 'Nothing to mount!' >> log.out",
      " else ",
      "sudo -s bash -c 'iscsiadm -m node -o new -T ${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].iqn} -p ${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].ipv4}:${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].port}'",
      "sudo -s bash -c 'iscsiadm -m node -o update -T ${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].iqn} -n node.startup -v automatic '",
      "sudo -s bash -c 'iscsiadm -m node -T ${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].iqn} -p ${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].ipv4}:${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].port} -l '",
      "sudo -s bash -c 'mkfs.ext4 -F /dev/${local.blk_vols_att_linux_list[count.index].dev_partition}'",
      "sudo -s bash -c 'mkdir -p ${local.blk_vols_att_linux_list[count.index].volume_mount_dir}'",
      "sudo -s bash -c 'mount -t ext4 /dev/${local.blk_vols_att_linux_list[count.index].dev_partition} ${local.blk_vols_att_linux_list[count.index].volume_mount_dir} '",
      "echo '/dev/${local.blk_vols_att_linux_list[count.index].dev_partition}  ${local.blk_vols_att_linux_list[count.index].volume_mount_dir} ext4 defaults,noatime,_netdev,nofail    0   10' | sudo tee --append /etc/fstab > /dev/null",
      " fi",
      ] : [
      "if mountpoint -q -- \"${local.blk_vols_att_linux_list[count.index].volume_mount_dir}\" ; ",
      " then ",
      "sudo -s bash -c 'umount -f ${local.blk_vols_att_linux_list[count.index].volume_mount_dir}'",
      "sudo -s bash -c 'rmdir -p ${local.blk_vols_att_linux_list[count.index].volume_mount_dir}'",
      "sudo -s bash -c 'iscsiadm -m node -T ${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].iqn} -p ${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].ipv4}:${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].port} -u'",
      "sudo -s bash -c 'iscsiadm -m node -o delete -T ${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].iqn} -p ${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].ipv4}:${local.blk_vols_att_vol_id[local.blk_vols_att_linux_list[count.index].volume_id].port}'",
      "sudo sed -ie  '\\|^/dev/${local.blk_vols_att_linux_list[count.index].dev_partition}|d' /etc/fstab",
      " else ",
      "echo 'Nothing to umount!' >> log.out",
      " fi",
    ]
  }
}


resource "oci_core_instance_console_connection" "this" {
  count      = length(local.comp_inst_console) > 0 ? length(local.comp_inst_console) : 0
  depends_on = [oci_core_instance.this]
  #Required
  instance_id = local.comp_inst[local.comp_inst_console[count.index].id].instance_id
  public_key  = chomp(file(local.comp_inst_console[count.index].ssh_authorized_keys[0]))

  #Optional
  defined_tags  = local.comp_inst_console[count.index].cons_conn_def_tags != null ? local.comp_inst_console[count.index].cons_conn_def_tags : local.def_tags_default
  freeform_tags = local.comp_inst_console[count.index].cons_conn_free_tags != null ? local.comp_inst_console[count.index].cons_conn_free_tags : local.free_tags_default
}
