provider "aws" {
  shared_credentials_file = "/home/rob/.aws/credentials"
  profile                 = "kfsoladmin"
  region                  = "${var.region}"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Looking up in map subnet_cidrs in variables.tf :
resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.my_vpc.id}"
  cidr_block = "${var.subnet_cidrs["public"]}"
}

# Looking up in map subnet_cidrs in variables.tf :
resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.my_vpc.id}"
  cidr_block = "${var.subnet_cidrs["private"]}"
}

# another static data source: a template file :
resource "aws_key_pair" "ecskeypair_publickey" {
  key_name   = "ecskeypair_publickey"
  public_key = "${file("~/.ssh/ecskeypair_publickey")}"
}

# external data source:
data "external" "example" {
  program = ["ruby", "${var.path.["externaldatasource"]}/custom_data_source.rb"]
}

module "appservermodule" {
  source    = "./modules/application"
  vpc_id    = "${aws_vpc.my_vpc.id}"
  subnet_id = "${aws_subnet.public.id}"
  name      = "postgress_cfa-${data.external.example.result.owner}" #you can access any JSON object key via the result attribute of external data source

  /* 'owner' is defined in the external ruby script */
  environment         = "${var.environment}"                                      # Overrriding var in module
  extra_sgs           = ["${aws_security_group.defaultssh.id}"]                   #pass xtra SG  to the module, wrapping it with square brackets
  extra_packages      = "${lookup(var.extra_packages, "MightyTrousers", "base")}"
  external_nameserver = "${var.external_nameserver}"

  # key_name: resource variables must be three parts: TYPE.NAME.ATTR
  key_name = "${aws_key_pair.ecskeypair_publickey.key_name}"
}

output "MODULEHOSTNAME" {
  value = "${module.appservermodule.hostname}"
}

# Making use of 'list variable' in cidr_blocks for allow_ssh_access
resource "aws_security_group" "defaultssh" {
  name        = "Default SG"
  description = "Allow SSH access"
  vpc_id      = "${aws_vpc.my_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ssh_access}"]
  }
}
