##############################################################################
# VPC GUID
##############################################################################

output vpc_id {
  description = "ID of VPC created"
  value       = ibm_is_vpc.vpc.id
}

##############################################################################


##############################################################################
# Subnet Outputs
##############################################################################

output subnet_ids {
  description = "List of subnet ids in vpc tier 1"
  value       = module.subnets.subnet_ids
}

output subnet_zone_list {
  description = "A map containing cluster subnet IDs and subnet zones"
  value       = module.subnets.subnet_zone_list
}

output subnet_detail_list {
  description = "A list of subnets containing names, CIDR blocks, and zones."
  value       = module.subnets.subnet_detail_list
}

##############################################################################


##############################################################################
# Proxy Subnet Outputs
##############################################################################

output proxy_subnet_detail {
  description = "A detailed object desribing the proxy subnet, CIDR block, and zone"
  value       = {
    (ibm_is_subnet.proxy_subnet.name) = {
      id = ibm_is_subnet.proxy_subnet.id
      cidr = ibm_is_subnet.proxy_subnet.ipv4_cidr_block
    }
  }
}

output proxy_subnet {
  description = "An object containing the proxy subnet CIDR blick and zone"
  value       = {
    id   = ibm_is_subnet.proxy_subnet.id
    cidr = ibm_is_subnet.proxy_subnet.ipv4_cidr_block
    zone = ibm_is_subnet.proxy_subnet.zone
  }
}

##############################################################################


##############################################################################
# ACL ID
##############################################################################

output acl_id {
  description = "ID of ACL created"
  value       = ibm_is_network_acl.multizone_acl.id
}

##############################################################################