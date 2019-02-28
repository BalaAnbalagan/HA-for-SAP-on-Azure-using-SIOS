# Resource Group Name will be RG-<SID>-<LOCATION> & RG will be hard coded
rg = "PG"

network_rg = "NETWORK"

vnet = "SPOKE"

subnet = "SPOKE-CORE"

location = "WESTUS2"

nfs_vm_type = "Standard_D4s_v3"

nfs_server_hostnamelist = ["pg-nfs01"]

nfs_server_niclist = ["11.1.1.11"]

nfs_ipmap = {
  "pg-nfs01" = "11.1.1.11"
}