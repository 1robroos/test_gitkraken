variable "region" {
  description = "AWS region. Changing it will lead to loss of complete stack."
  default     = "eu-central-1"
}

# Force "dev" ( module has "test" as default but will be overridden by the var declaration in this root module)
variable "environment" {
  default = "dev"
}

variable "allow_ssh_access" {
  description = "List of CIDR blocks that can access instances via SSH"
  default     = ["86.93.45.48/32"]                                      # ip Rob home
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  type = "map"

  description = "CIDR blocks for public and private subnets"

  default = {
    public  = "10.0.1.0/24"
    private = "10.0.2.0/24"
  }
}

variable "external_nameserver" {
  default = "8.8.8.8"
}

variable "path" {
  type = "map"

  description = "path to some files"

  default = {
    externaldatasource = "/home/rob/Documents/github/test_gitkraken"
  }
}

variable "extra_packages" {
  description = "Additional packages to install for particular module"

  default = {
    MightyTrousers = "wget bind-utils"
  }
}
