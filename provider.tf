terraform {
  required_providers {
    mysql = {
      source  = "petoju/mysql"
      version = "3.0.64"
    }
  }
}

provider "mysql" {
  alias    = "local"
  endpoint = "127.0.0.1:3307"
  username = "root"
  password = "rootpassword"
}
