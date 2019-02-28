# Group for all this resources

rg = "NETWORK"

#network_rg = "NETWORK"

location = ["WESTUS2"]

# HUB &  SPOKE  Virtual Network  

vnet = ["HUB", "SPOKE"]

vnet_cidr = ["11.0.0.0/16", "11.1.0.0/16"]

vnet_cidrmap = {
  "HUB"   = "11.0.0.0/16"
  "SPOKE" = "11.1.0.0/16"
}

#  Hub subnet
subnets_hub_names = ["GATEWAY", "DMZ"]

subnet_hub_cidr = ["11.0.0.0/24", "11.0.1.0/24"]

subnet_hub_cidrmap = {
  "GATEWAY" = "11.0.0.0/24"
  "DMZ"     = "11.0.1.0/24"
}

# Spoke subnet

subnets_spoke_names = ["CORE", "SIOS"]

subnet_spoke_cidr = ["11.1.1.0/24", "11.1.2.0/24"]

subnet_spoke_cidrmap = {
  "CORE"        = "11.1.1.0/24"
  "SIOS"         = "11.1.2.0/24"

}

# Primary Region = WESTUS2
# Secondary Redgion = EASTUS2

#TAG MAP

tags_map = {
  Environment   = "Microsoft Lab"
  Created_By    = "Bala Anbalagan"
  Created_Using = "Terraform"
}
