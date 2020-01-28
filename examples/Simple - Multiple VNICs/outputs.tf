# Copyright (c) 2020 Oracle and/or its affiliates,  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https: //oss.oracle.com/licenses/upl.


output "network" {
  description = "network"
  value       = module.oci_network
}

output "subnet" {
  description = "Subnet"
  value       = module.oci_subnets
}

output "instances" {
  description = "Instance"
  value       = module.oci_instances
}

