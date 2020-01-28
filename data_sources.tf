# Copyright (c) 2020 Oracle and/or its affiliates,  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


# Availability Domains

data "oci_identity_availability_domains" "this" {
  compartment_id = var.default_compartment_id
}

data "oci_core_images" "this" {
  #Required
  compartment_id = var.default_compartment_id

  filter {
    name   = "state"
    values = ["AVAILABLE"]
  }

}

data "oci_core_services" "this" {
}