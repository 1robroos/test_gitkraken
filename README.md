# Gitkraken test repository
## Try out gitkraken stuff

### Inspec
Make use of Inspec to check if wget is installed ( in specs dir it gives a ruby script for that).
The only thing that prevents us from running this test is the missing IP address of the instance. So an extra output var
aws_instance.app-server.public_ip is used for that.

~~~
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken$ terraform plan| grep -v computed
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.external.example: Refreshing state...
data.template_file.user_data: Refreshing state...
data.aws_ami.app-ami: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

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
      map_public_ip_on_launch:               "true"
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
      key_name:                              "ecskeypair_publickey"
      source_dest_check:                     "true"
      subnet_id:                             "${var.subnet_id}"
      tags.%:                                "1"
      tags.Name:                             "postgress_cfa-Packt"
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
      name:                                  "postgress_cfa-Packt allow_http"
      revoke_rules_on_delete:                "false"
      vpc_id:                                "${var.vpc_id}"


Plan: 7 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

~~~
After terraform apply it gives:
~~~
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

MODULEHOSTNAME = ip-10-0-1-78.eu-central-1.compute.internal
appservermodule_public_ip = 18.185.110.8
~~~

## Now the beautiful part :

 ~~~
 rob@rob-Latitude-5590:~/Documents/github/test_gitkraken
 $ inspec exec specs/base_spec.rb -t ssh://ubuntu@$(terraform output appservermodule_public_ip) -i ~/.ssh/ecskeypair.pem
verify_host_key: false is deprecated, use :never

Profile: tests from specs/base_spec.rb (tests from specs.base_spec.rb)
Version: (not specified)
Target:  ssh://ubuntu@18.185.110.8:22

  System Package wget
     ✔  should be installed

Test Summary: 1 successful, 0 failures, 0 skipped
~~~

So with inspec we were able to check if wget is installed in the deployed instance!

### Another inspec example
Another example with inspec: Follow https://learn.chef.io/modules/try-inspec#/ for this:

~~~
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken$ mkdir inspec
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken$ cd inspec/
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken/inspec$ git clone https://github.com/learn-chef/auditd.git
Cloning into 'auditd'...
remote: Enumerating objects: 7, done.
remote: Total 7 (delta 0), reused 0 (delta 0), pack-reused 7
Unpacking objects: 100% (7/7), done.
~~~
Show the script:
~~~
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken/inspec$ cat auditd/controls/example.rb
describe package('auditd') do
  it { should be_installed }
end
~~~
The code you see is InSpec. This test states that the package auditd should be installed.
It expresses the same requirement as the dpkg -s auditd

To quickly test it on my laptop:
~~~
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken/inspec$ inspec exec auditd/

Profile: InSpec Profile (auditd)
Version: 0.1.0
Target:  local://

  System Package auditd
     ×  should be installed
     expected that `System Package auditd` is installed

Test Summary: 0 successful, 1 failure, 0 skipped
~~~
Now incorporate it into terraform template: Doesn't work. Needs more investigation.
See also https://lollyrock.com/articles/inspec-terraform/
