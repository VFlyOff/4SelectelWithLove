terraform {
  required_version = ">= 0.14.0"
  required_providers {
    selectel = {
      source = "selectel/selectel"
      version = "4.0.1-alpha"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.51.0"
    }
  }
}

provider "selectel" {
  domain_name = "<id>"
  username = "<uname>"
  password = "<pass>"
  token = "<token>"
}

provider "openstack" {
  auth_url = "https://api.selvpc.ru/identity/v3"
  domain_name = "<id>"
  tenant_id = "<proj_id>"
  user_name = "<uname>"
  password = "<pass>"
  region = "<pool>"
}  
