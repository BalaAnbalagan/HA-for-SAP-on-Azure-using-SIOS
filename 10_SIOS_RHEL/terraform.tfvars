sid = "S4P"

# Resource Group Name will be RG-<SID>-<LOCATION> & RG will be hard coded
rg = "SIOS_RHEL"

network_rg = "NETWORK"

vnet = "SPOKE"

subnet = "SPOKE-SIOS"

location = "WESTUS2"

# SCS Variables

scs_vm_type = "Standard_D2s_v3"

scs_server_hostnamelist = ["azrhs4p11", "azrhs4p12"]

scs_server_niclist = ["11.1.2.11", "11.1.2.12"]

scs_ipmap = {
  "azrhs4p11" = "11.1.2.11"
  "azrhs4p12" = "11.1.2.12"
}

wd_vm_type = "Standard_D2s_v3"

wd_server_hostnamelist = ["azrhs4p13", "azrhs4p14"]

wd_server_niclist = ["11.1.2.13", "11.1.2.14"]

wd_ipmap = {
  "azrhs4p13" = "11.1.2.13"
  "azrhs4p14" = "11.1.2.14"
}

sios_vm_type = "Standard_B2s"

sios_server_hostnamelist = ["azrhs4p15", "azrhs4p16"]

sios_server_niclist = ["11.1.2.15", "11.1.2.16"]

sios_ipmap = {
  "azrhs4p15" = "11.1.2.15"
  "azrhs4p16" = "11.1.2.16"
}

app_vm_type = "Standard_D4s_v3"
 
app_server_hostnamelist = ["azrhs4p21", "azrhs4p22"]

app_server_niclist = ["11.1.2.21", "11.1.2.22"]

app_server_ipmap = {
  "azrhs4p21" = "11.1.2.21"
  "azrhs4p22" = "11.1.2.22"
}

db_vm_type = "Standard_M32ms"

db_server_hostnamelist = ["azrhs4p31", "azrhs4p32"]

db_server_niclist = ["11.1.2.31", "11.1.2.32"]

db_server_ipmap = {
  "azrhs4p31" = "11.1.2.31"
  "azrhs4p32" = "11.1.2.32"
}

