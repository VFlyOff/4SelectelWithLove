terraform {
  required_version = ">= 0.14.0"
  required_providers {
    selectel = {
      source = "selectel/selectel"
      version = "4.0.1-alpha"
    }
  }
}

provider "selectel" {
    domain_name = "id"
    username = "user"
    password = "pass"
    token = "token"
}
