# Gitkraken test repository
## Try out gitkraken stuff
### Branch develop will have multiple branches
#### this is about a template file.
A template file is used for the key_name and also for user_data ( cloud-init )

For the key_name:
Define a template: resource "aws_key_pair"
USe it in the root module at the module definition:  key_name = "${aws_key_pair.ecskeypair_publickey.key_name}"
IN the applicaiotn module a var needs to be defined:variable "key_name" {}
And in the module itself it is defined as:   key_name               = "${var.key_name}"

A lot of actions for a template file !

The usage of the template file for the cloud init looks like:
  IN the application module:  
      user_data              = "${data.template_file.user_data.rendered}"
      data template is defined:data "template_file" "user_data"
  IN the directory of this application module: file user_data.sh.tpl exists 



The terraform plan gives this output:
~~~
Terraform will perform the following actions:

  + aws_key_pair.ecskeypair_publickey
      key_name:                              "ecskeypair_publickey"
      public_key:                            "---- BEGIN SSH2 PUBLIC KEY ----\r\nComment: \"imported-openssh-key\"\r\nAAAAB3NzaC1yc2EAAAADAQABAAABAQDGlSWGNpRvGAGqB3twjinbuHPRh5YTIxxE\r\nGAZQizV28+UTBBmRNX3V3xGd8AU0a1gh8QSak6wbrPZ2L/X+/w5We3NGpvmSJMMP\r\n4aC7y1XOYEBNrQgCAy920EAg28Rg4VFAHkTpqmjvq+XCNhTmaOaZo9QpcYZUL6hI\r\nZmHU+t4PnREBArwnRgguMM2MirtI/NpMQF0WZmhqenKNxBijZp7wgxza5+0GfDxZ\r\n/rHhdY/9revuE+IiOX0QDLf8lG7pG50aGl2hpg58av3vIgX6+NL9XhvZv8/NTW0V\r\nyIHRMAnbJdKyg0y4uQgRpLDKSCb9AN7f0M1qmvtxq0ifu9PYRgHz\r\n---- END SSH2 PUBLIC KEY ----"

  + aws_security_group.defaultssh
      description:                           "Allow SSH access"
      ingress.#:                             "1"
      ingress.2912756588.cidr_blocks.#:      "1"
      ingress.2912756588.cidr_blocks.0:      "86.93.45.48/32"
      ingress.2912756588.description:        ""
      ingress.2912756588.from_port:          "22"
      ingress.2912756588.ipv6_cidr_blocks.#: "0"
      ingress.2912756588.prefix_list_ids.#:  "0"
      ingress.2912756588.protocol:           "tcp"
      ingress.2912756588.security_groups.#:  "0"
      ingress.2912756588.self:               "false"
      ingress.2912756588.to_port:            "22"
      name:                                  "Default SG"
      revoke_rules_on_delete:                "false"
      vpc_id:                                "${aws_vpc.my_vpc.id}"

  + aws_subnet.private
      assign_ipv6_address_on_creation:       "false"
      cidr_block:                            "10.0.2.0/24"
      map_public_ip_on_launch:               "false"
      vpc_id:                                "${aws_vpc.my_vpc.id}"

  + aws_subnet.public
      assign_ipv6_address_on_creation:       "false"
      cidr_block:                            "10.0.1.0/24"
      map_public_ip_on_launch:               "false"
      vpc_id:                                "${aws_vpc.my_vpc.id}"

  + aws_vpc.my_vpc
      assign_generated_ipv6_cidr_block:      "false"
      cidr_block:                            "10.0.0.0/16"
      enable_dns_support:                    "true"
      instance_tenancy:                      "default"

  + module.appservermodule.aws_instance.app-server
      ami:                                   "ami-06820af6cb0a33adf"
      get_password_data:                     "false"
      instance_type:                         "t2.micro"
      source_dest_check:                     "true"
      subnet_id:                             "${var.subnet_id}"
      tags.%:                                "1"
      key_name:                              "ecskeypair_publickey"
      tags.Name:                             "postgress_cfa"
      user_data:                             "5f32ca44b854f354a3fa2ae3f0d3a0f3f1f78b1e"

  + module.appservermodule.aws_security_group.allow_http
      description:                           "Allow HTTP traffic"
      egress.#:                              "1"
      egress.482069346.cidr_blocks.#:        "1"
      egress.482069346.cidr_blocks.0:        "0.0.0.0/0"
      egress.482069346.description:          ""
      egress.482069346.from_port:            "0"
      egress.482069346.ipv6_cidr_blocks.#:   "0"
      egress.482069346.prefix_list_ids.#:    "0"
      egress.482069346.protocol:             "-1"
      egress.482069346.security_groups.#:    "0"
      egress.482069346.self:                 "false"
      egress.482069346.to_port:              "0"
      ingress.#:                             "1"
      ingress.2214680975.cidr_blocks.#:      "1"
      ingress.2214680975.cidr_blocks.0:      "0.0.0.0/0"
      ingress.2214680975.description:        ""
      ingress.2214680975.from_port:          "80"
      ingress.2214680975.ipv6_cidr_blocks.#: "0"
      ingress.2214680975.prefix_list_ids.#:  "0"
      ingress.2214680975.protocol:           "tcp"
      ingress.2214680975.security_groups.#:  "0"
      ingress.2214680975.self:               "false"
      ingress.2214680975.to_port:            "80"
      name:                                  "postgress_cfa allow_http"
      revoke_rules_on_delete:                "false"
      vpc_id:                                "${var.vpc_id}"


Plan: 7 to add, 0 to change, 0 to destroy.
~~~

The output of terraform apply is:
~~~
Outputs:

MODULEHOSTNAME = ip-10-0-1-183.eu-central-1.compute.internal
~~~

After the apply we can ask for that output:
~~~
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken$ terraform  output
MODULEHOSTNAME = ip-10-0-1-183.eu-central-1.compute.internal
~~~
Voor iedere instance die met de module is gecreerd kun je de hostname uitlezen:
~~~
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken$ terraform output -module=appservermodule hostname
ip-10-0-1-183.eu-central-1.compute.internal
~~~
