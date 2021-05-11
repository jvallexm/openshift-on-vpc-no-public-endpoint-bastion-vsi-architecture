
##############################################################################
# Create an  ACL for ingress/egress used by  all subnets in VPC
##############################################################################

locals {

      subnet_cidr_list = flatten([
            [
                  # for each zone in the cidr blocks map
                  for zone in keys(var.cidr_blocks): 
                  [
                        # Create an object containing the rule name and the CIDR block
                        for cidr in var.cidr_blocks[zone]:
                        {
                              # Format name zone-<>-subnet-<>
                              name = "zone-${
                                    index(keys(var.cidr_blocks), zone) + 1
                              }-subnet-${
                                    index(var.cidr_blocks[zone], cidr) + 1
                              }"
                              cidr = cidr
                        }
                  ]
            ],
            [
                  {
                        name = "proxy-subnet"
                        cidr = var.proxy_subnet_cidr
                  }
            ]
      ])

      allow_subnet_cidr_rules = flatten([
            [
                  # ROKS Rules
                  {
                        name        = "roks-create-worker-nodes-inbound"
                        action      = "allow"
                        source      = "161.26.0.0/16"
                        destination = "0.0.0.0/0"
                        direction   = "inbound"
                  },
                  {
                        name        = "roks-nodes-to-service-inbound"
                        action      = "allow"
                        source      = "166.8.0.0/14"
                        destination = "0.0.0.0/0"
                        direction   = "inbound"
                  },
                  {
                        name        = "roks-create-worker-nodes-outbound"
                        action      = "allow"
                        destination = "161.26.0.0/16"
                        source      = "0.0.0.0/0"
                        direction   = "outbound"
                  },
                  {
                        name        = "roks-nodes-to-service-outbound"
                        action      = "allow"
                        destination = "166.8.0.0/14"
                        source      = "0.0.0.0/0"
                        direction   = "outbound"
                  },
                  # App Rules
                  {
                        name        = "allow-app-incoming-traffic-requests"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = "0.0.0.0/0"
                        direction   = "inbound"
                        tcp         = {
                              port_min        = 1
                              port_max        = 65535
                              source_port_min = 30000
                              source_port_max = 32767
                        }
                  },
                  {
                        name        = "allow-app-outgoing-traffic-requests"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = "0.0.0.0/0"
                        direction   = "outbound"
                        tcp         = {
                              source_port_min = 1
                              source_port_max = 65535
                              port_min        = 30000
                              port_max        = 32767
                        }
                  },
                  {
                        name        = "allow-lb-incoming-traffic-requests"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = "0.0.0.0/0"
                        direction   = "inbound"
                        tcp         = {
                              source_port_min = 1
                              source_port_max = 65535
                              port_min        = 443
                              port_max        = 443
                        }
                  },
                  {
                        name        = "allow-lb-outgoing-traffic-requests"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = "0.0.0.0/0"
                        direction   = "outbound"
                        tcp         = {
                              port_min        = 1
                              port_max        = 65535
                              source_port_min = 443
                              source_port_max = 443
                        }
                  }
            ],
            # Create rules that allow incoming traffic from subnets
            [
                  for subnet in local.subnet_cidr_list:           
                  {
                        name        = "allow-traffic-${subnet.name}-inbound"
                        action      = "allow"
                        source      = subnet.cidr
                        destination = "0.0.0.0/0"
                        direction   = "inbound"
                  }
            ],
            # Create rules to allow outbound traffic to subnets
            [
                  for subnet in local.subnet_cidr_list:           
                  {
                        name        = "allow-traffic-${subnet.name}-outbound"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = subnet.cidr
                        direction   = "outbound"
                  }
            ],
            # Rules to allow proxy subnet to access all incoming and outgoing traffic
            [
                  {
                        name        = "allow-all-traffic-proxy-inbound"
                        action      = "allow"
                        source      = "0.0.0.0/0"
                        destination = var.proxy_subnet_cidr
                        direction   = "inbound"
                  },
                  {
                        name        = "allow-all-traffic-proxy-outbound"
                        action      = "allow"
                        destination = "0.0.0.0/0"
                        source      = var.proxy_subnet_cidr
                        direction   = "outbound"
                  }
            ]
      ])

      acl_rules = flatten(
            [
                  var.acl_rules,
                  local.allow_subnet_cidr_rules
            ]
      )
}

resource ibm_is_network_acl multizone_acl {
      name           = "${var.unique_id}-acl"
      vpc            = ibm_is_vpc.vpc.id
      resource_group = var.resource_group_id

      # Create ACL rules
      dynamic rules {
            for_each = local.acl_rules
            content {
                  name        = rules.value.name
                  action      = rules.value.action
                  source      = rules.value.source
                  destination = rules.value.destination
                  direction   = rules.value.direction

                  ##############################################################################
                  # Dynamically create TCP rules
                  ##############################################################################

                  dynamic tcp {

                        # Runs a for each loop, if the rule block contains tcp, it looks through the block
                        # Otherwise the list will be empty     

                        for_each = (
                              contains(keys(rules.value), "tcp")
                              ? [rules.value]
                              : []
                        )

                        # Conditionally adds content if sg has tcp
                        content {

                              port_min = lookup(
                                    lookup(
                                          rules.value, 
                                          "tcp"
                                    ), 
                                    "port_min"
                              )

                              port_max = lookup(
                                    lookup(
                                          rules.value, 
                                          "tcp"
                                    ), 
                                    "port_max"
                              )

                              source_port_min = lookup(
                                    lookup(
                                          rules.value, 
                                          "tcp"
                                    ), 
                                    "source_port_min"
                              )

                              source_port_max = lookup(
                                    lookup(
                                          rules.value, 
                                          "tcp"
                                    ), 
                                    "source_port_max"
                              )
                        }
                  } 

                  ##############################################################################

                  ##############################################################################
                  # Dynamically create UDP rules
                  ##############################################################################

                  dynamic udp {

                        # Runs a for each loop, if the rule block contains tcp, it looks through the block
                        # Otherwise the list will be empty     

                        for_each = (
                              contains(keys(rules.value), "udp")
                              ? [rules.value]
                              : []
                        )

                        # Conditionally adds content if sg has udp
                        content {

                              port_min = lookup(
                                    lookup(
                                          rules.value, 
                                          "udp"
                                    ), 
                                    "port_min"
                              )

                              port_max = lookup(
                                    lookup(
                                          rules.value, 
                                          "udp"
                                    ), 
                                    "port_max"
                              )
                              
                              source_port_min = lookup(
                                    lookup(
                                          rules.value, 
                                          "udp"
                                    ), 
                                    "source_port_min"
                              )

                              source_port_max = lookup(
                                    lookup(
                                          rules.value, 
                                          "udp"
                                    ), 
                                    "source_port_max"
                              )
                        }
                  } 

                  ##############################################################################

                  ##############################################################################
                  # Dynamically create ICMP rules
                  ##############################################################################

                  dynamic icmp {

                        # Runs a for each loop, if the rule block contains icmp, it looks through the block
                        # Otherwise the list will be empty     

                        for_each = (
                              contains(keys(rules.value), "icmp")
                              ? [rules.value]
                              : []
                        )

                        # Conditionally adds content if sg has icmp
                        content {

                              type = lookup(
                                    lookup(
                                          rules.value, 
                                          "icmp"
                                    ), 
                                    "type"
                              )

                              code = lookup(
                                    lookup(
                                          rules.value, 
                                          "icmp"
                                    ), 
                                    "code"
                              )
                        }
                  } 

                  ##############################################################################

            }
      }
}

##############################################################################