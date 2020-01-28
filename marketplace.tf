# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  mkp_image_details = local.mkp_instances == null ? {} : {
    for k, v in local.mkp_instances : k => {
      mkp_image_name                      = v.mkp_image_name
      mkp_image_version                   = v.mkp_image_name_version
      mkp_image_ocid                      = data.oci_core_app_catalog_listing_resource_version.app_catalog_listing_resource_version[k].listing_resource_id
      mkp_image_time_published            = data.oci_core_app_catalog_listing_resource_version.app_catalog_listing_resource_version[k].time_published
      mkp_image_agreement_id              = oci_marketplace_accepted_agreement.accepted_agreements[k].id
      mkp_image_agreement_name            = oci_marketplace_accepted_agreement.accepted_agreements[k].display_name
      mkp_image_agreement_accept_time     = oci_marketplace_accepted_agreement.accepted_agreements[k].time_accepted
      mkp_image_publisher                 = data.oci_marketplace_listing.listing[k].publisher[0].name
      mkp_image_publisher_email           = data.oci_marketplace_listing.listing[k].publisher[0].contact_email
      mkp_image_publisher_phone           = data.oci_marketplace_listing.listing[k].publisher[0].contact_phone
      mkp_image_license_model_description = data.oci_marketplace_listing.listing[k].license_model_description
    }
  }
}

resource "oci_marketplace_accepted_agreement" "accepted_agreements" {
  for_each = local.mkp_instances == null ? {} : local.mkp_instances

  agreement_id    = oci_marketplace_listing_package_agreement.listing_package_agreement[each.key].agreement_id
  compartment_id  = var.default_compartment_id
  listing_id      = data.oci_marketplace_listing.listing[each.key].id
  package_version = data.oci_marketplace_listing.listing[each.key].default_package_version
  signature       = oci_marketplace_listing_package_agreement.listing_package_agreement[each.key].signature
}

resource "oci_marketplace_listing_package_agreement" "listing_package_agreement" {
  for_each = local.mkp_instances == null ? {} : local.mkp_instances

  agreement_id    = data.oci_marketplace_listing_package_agreements.listing_package_agreements[each.key].agreements.0.id
  listing_id      = data.oci_marketplace_listing.listing[each.key].id
  package_version = data.oci_marketplace_listing.listing[each.key].default_package_version
}

data "oci_marketplace_listing_package_agreements" "listing_package_agreements" {
  for_each = local.mkp_instances == null ? {} : local.mkp_instances

  listing_id      = data.oci_marketplace_listing.listing[each.key].id
  package_version = data.oci_marketplace_listing.listing[each.key].default_package_version
}

data "oci_marketplace_listing_package" "listing_package" {
  for_each = local.mkp_instances == null ? {} : local.mkp_instances

  listing_id      = data.oci_marketplace_listing.listing[each.key].id
  package_version = each.value.mkp_image_name_version
}

data "oci_marketplace_listing_packages" "listing_packages" {
  for_each = local.mkp_instances == null ? {} : local.mkp_instances

  listing_id = data.oci_marketplace_listing.listing[each.key].id
}

data "oci_marketplace_listing" "listing" {
  for_each = local.mkp_instances == null ? {} : local.mkp_instances

  listing_id = data.oci_marketplace_listings.listings[each.key].listings.0.id
}

data "oci_marketplace_listings" "listings" {
  for_each = local.mkp_instances == null ? {} : local.mkp_instances

  name = [each.value.mkp_image_name]
}

data "oci_core_app_catalog_listings" "app_catalog_listings" {
  for_each = local.mkp_instances == null ? {} : local.mkp_instances
  #Optional
  display_name = each.value.mkp_image_name
}


data "oci_core_app_catalog_listing_resource_version" "app_catalog_listing_resource_version" {
  for_each = local.mkp_instances == null ? {} : local.mkp_instances
  #Required
  listing_id       = data.oci_core_app_catalog_listings.app_catalog_listings[each.key].app_catalog_listings[0].listing_id
  resource_version = each.value.mkp_image_name_version
}

