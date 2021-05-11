##############################################################################
# VPC Outputs
##############################################################################

output vpc_id {
  description = "ID of VPC created"
  value       = module.vpc.vpc_id
}

output acl_id {
    description = "ID of ACL Created for the VPC"
    value       = module.vpc.acl_id
}

output subnet_zone_list {
    description = "A map containing cluster subnet IDs and subnet zones"
    value       = module.vpc.subnet_zone_list
}

output subnet_detail_list {
  description = "A list of subnets containing names, CIDR blocks, and zones."
  value       = module.vpc.subnet_detail_list
}

output proxy_subnet_detail {
  description = "A detailed object desribing the proxy subnet, CIDR block, and zone"
  value       = module.vpc.proxy_subnet_detail
}

##############################################################################


##############################################################################
# Resource Outputs
##############################################################################

output cos_id {
    description = "ID of COS instance"
    value       = module.resources.cos_id
}

output kms_guid {
    description = "GUID of Key Protect Instance"
    value       = module.resources.kms_guid
}

output ibm_managed_key_id {
    description = "GUID of User Managed Key"
    value       = module.resources.ibm_managed_key_id
}

##############################################################################


##############################################################################
# Cluster Outputs
##############################################################################

output cluster_id {
    description = "ID of cluster created"
    value       = module.roks_cluster.cluster_id
}

output cluster_name {
    description = "Name of cluster created"
    value       = module.roks_cluster.cluster_name
}

output cluster_private_service_endpoint_url {
    description = "URL For Cluster Private Service Endpoint"
    value       = module.roks_cluster.cluster_private_service_endpoint_url
}

output cluster_private_service_endpoint_port {
    description = "Port for Cluster private service endpoint"
    value       = module.roks_cluster.cluster_private_service_endpoint_port
}

##############################################################################


##############################################################################
# VSI Outputs
##############################################################################

output linux_vsi_info {
    description = "Information for the Linux VSI"
    value       = module.bastion_vsi.linux_vsi_info
}

output windows_vsi_info {
    description = "Information for the Windows Server VSI"
    value       = module.bastion_vsi.windows_vsi_info
}

##############################################################################