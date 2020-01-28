# Copyright (c) 2020 Oracle and/or its affiliates,  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Instances

output "instance" {
  description = "The returned resource attributes for the VCN."
  value = {
    for x in oci_core_instance.this :
    x.display_name => x
  }
}

output "oci_core_vnic_attachment" {
  description = "Secondary VNICs attached"
  value       = oci_core_vnic_attachment.this
}

output "volume_attachment" {
  description = "Block Storage attached"
  value       = oci_core_volume_attachment.this
}

output "oci_mkp_agreements" {
  description = "OCI Market Place Instance Agreements"
  value       = local.mkp_image_details
}



