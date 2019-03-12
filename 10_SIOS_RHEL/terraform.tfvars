sid = "S4P"

# Resource Group Name will be RG-<SID>-<LOCATION> & RG will be hard coded
rg = "SIOS_RHEL"

network_rg = "NETWORK"

vnet = "SPOKE"

subnet = "SPOKE-SIOS"

location = "WESTUS2"

# SCS Variables

scs_vm_type = "Standard_D2s_v3"

scs_server_hostnamelist = ["azrhascs1", "azrhascs2"]

scs_server_niclist = ["11.1.2.11", "11.1.2.12"]

scs_ipmap = {
  "azrhascs1" = "11.1.2.11"
  "azrhascs2" = "11.1.2.12"
}

wd_vm_type = "Standard_D2s_v3"

wd_server_hostnamelist = ["azrhs4p13", "azrhs4p14"]

wd_server_niclist = ["11.1.2.13", "11.1.2.14"]

wd_ipmap = {
  "azrhs4p13" = "11.1.2.13"
  "azrhs4p14" = "11.1.2.14"
}

sios_vm_type = "Standard_B2s"

sios_server_hostnamelist = ["azrhsapwit1", "azrhsapwit2"]

sios_server_niclist = ["11.1.2.15", "11.1.2.16"]

sios_ipmap = {
  "azrhsapwit1" = "11.1.2.15"
  "azrhsapwit2" = "11.1.2.16"
}

app_vm_type = "Standard_D4s_v3"
 
app_server_hostnamelist = ["azrhsap1", "azrhsap2"]

app_server_niclist = ["11.1.2.21", "11.1.2.22"]

app_server_ipmap = {
  "azrhsap1" = "11.1.2.21"
  "azrhsap2" = "11.1.2.22"
}

db_vm_type = "Standard_M8ms"

db_server_hostnamelist = ["azrhhana1", "azrhhana2"]

db_server_niclist = ["11.1.2.31", "11.1.2.32"]

db_server_ipmap = {
  "azrhhana1" = "11.1.2.31"
  "azrhhana2" = "11.1.2.32"
}

