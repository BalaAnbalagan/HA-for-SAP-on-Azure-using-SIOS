
rg = "PG"

network_rg = "NETWORK"

vnet = "SPOKE"

subnet = "SPOKE-CORE"

location = "WESTUS2"

dns_server_hostnamelist = ["PG-DNS00"]

dns_server_niclist = ["11.1.1.5"]

dns_ipmap = {
  "PG-DNS00" = "11.1.1.5"
}
