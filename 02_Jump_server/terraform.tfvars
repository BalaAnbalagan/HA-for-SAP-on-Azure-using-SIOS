
rg = "PG"

network_rg = "NETWORK"

vnet = "HUB"

subnet = "HUB-DMZ"

location = "WESTUS2"

jump_server_hostnamelist = ["PG-RDP00", "PG-RDP01"]

jump_server_niclist = ["11.0.1.5","11.0.1.6"]

jump_ipmap = {
  "PG-RDP00" = "11.0.1.5"
  "PG-RDP01" = "11.0.1.6"
}
