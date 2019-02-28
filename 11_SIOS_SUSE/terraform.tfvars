sid = "S4D"

# Resource Group Name will be RG-<SID>-<LOCATION> & RG will be hard coded
rg = "SIOS-SUSE"

network_rg = "NETWORK"

vnet = "SPOKE"

subnet = "SPOKE-SIOS"

location = "WESTUS2"

# SCS Variables

scs_vm_type = "Standard_D2s_v3"

scs_server_hostnamelist = ["azsuascs1", "azsuers1"]

scs_server_niclist = ["11.1.2.61", "11.1.2.62"]

scs_ipmap = {
  "azsuascs1" = "11.1.2.61"
  "azsuers1" = "11.1.2.62"
}

wd_vm_type = "Standard_D2s_v3"

wd_server_hostnamelist = ["azrhs4p13", "azrhs4p14"]

wd_server_niclist = ["11.1.2.13", "11.1.2.14"]

wd_ipmap = {
  "azrhs4p13" = "11.1.2.13"
  "azrhs4p14" = "11.1.2.14"
}

sios_vm_type = "Standard_B2s"

sios_server_hostnamelist = ["azsusapwit1", "azsusapwit2" ]

sios_server_niclist = ["11.1.2.65", "11.1.2.66"]

sios_ipmap = {
  "azsusapwit1" = "11.1.2.65"
  "azsusapwit2" = "11.1.2.66"
}

app_vm_type = "Standard_D4s_v3"
 
app_server_hostnamelist = ["azsusap1", "azsusap2"]

app_server_niclist = ["11.1.2.53", "11.1.2.54"]

app_server_ipmap = {
  "azsusap1" = "11.1.2.53"
  "azsusap2" = "11.1.2.54"
}

db_vm_type = "Standard_M32ms"

db_server_hostnamelist = ["azsuhana1", "azsuhana2"]

db_server_niclist = ["11.1.2.51", "11.1.2.52"]

db_server_ipmap = {
  "azsuhana1" = "11.1.2.51"
  "azsuhana2" = "11.1.2.52"
}

