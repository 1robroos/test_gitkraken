# Gitkraken test repository
## Try out gitkraken stuff


### Let's test a local-exec

Because the aws environment already exist and only the aws instance
needs to be rebuilded: we will taint that instance:

~~~
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken$ terraform state list
aws_default_route_table.default_routing
aws_internet_gateway.gw
aws_key_pair.ecskeypair_publickey
aws_security_group.defaultssh
aws_subnet.private
aws_subnet.public
aws_vpc.my_vpc
external.example
module.appservermodule.aws_ami.app-ami
module.appservermodule.aws_instance.app-server
module.appservermodule.aws_security_group.allow_http
module.appservermodule.template_file.user_data

rob@rob-Latitude-5590:~/Documents/github/test_gitkraken$ terraform taint module.appservermodule.aws_instance.app-server
Failed to parse resource name: Malformed resource state key: module.appservermodule.aws_instance.app-server

rob@rob-Latitude-5590:~/Documents/github/test_gitkraken$ terraform taint -module=appservermodule  aws_instance.app-server
The resource aws_instance.app-server in the module root.appservermodule has been marked as tainted!

~~~
I made an error: I added the local-exec in the module definition in the root module:
~~~
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken$ terraform  apply

Error: module "appservermodule": self variables are only valid within resources
Error: module 'appservermodule': cannot contain self-reference self.public_ip
Error: module "appservermodule": "provisioner" is not a valid argument

~~~

It must be added in the application module.
So in the application module I added:
provisioner "local-exec" {
  command = "echo ${self.public_ip} >> inventory"
}

After terraform apply it gives:


~~~
Outputs:

MODULEHOSTNAME = ip-10-0-1-239.eu-central-1.compute.internal
appservermodule_public_ip = 18.197.96.98
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken$ ls -ltr
total 80
drwxr-xr-x 3 rob rob  4096 sep 15 19:54 modules
-rw-r--r-- 1 rob rob    66 sep 24 15:10 custom_data_source.rb
drwxr-xr-x 2 rob rob  4096 sep 24 21:52 specs
drwxr-xr-x 3 rob rob  4096 sep 25 03:40 inspec
-rw-r--r-- 1 rob rob  1093 sep 25 03:47 variables.tf
-rw-r--r-- 1 rob rob  2853 sep 25 04:28 template.tf
-rw-r--r-- 1 rob rob 23042 sep 25 04:30 terraform.tfstate.backup
-rw-r--r-- 1 rob rob    13 sep 25 04:30 inventory
-rw-r--r-- 1 rob rob 23047 sep 25 04:30 terraform.tfstate
-rw-rw-r-- 1 rob rob  1728 sep 25 04:31 README.md
~~~

And the inventory file holds:
~~~
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken$ cat inventory
18.197.96.98
~~~
Now testing ansible:
~~~
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken
$ ansible all -i inventory -a  " cat /etc/hosts " -u ubuntu
The authenticity of host '18.197.96.98 (18.197.96.98)' can't be established.
ECDSA key fingerprint is SHA256:sBpOmkj4P2+PL4YPJ196447oVMcTpwzfisk3U+eOS40.
Are you sure you want to continue connecting (yes/no)? yes
18.197.96.98 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Warning: Permanently added '18.197.96.98' (ECDSA) to the list of known hosts.\r\nubuntu@18.197.96.98: Permission denied (publickey).\r\n",
    "unreachable": true
}
~~~
Again but now with key file :
~~~
rob@rob-Latitude-5590:~/Documents/github/test_gitkraken$ ansible all --private-key=~/.ssh/ecskeypair.pem -i inventory -a  " cat /etc/hosts " -u ubuntu
18.197.96.98 | FAILED! => {
    "changed": false,
    "module_stderr": "Shared connection to 18.197.96.98 closed.\r\n",
    "module_stdout": "/bin/sh: 1: /usr/bin/python: not found\r\n",
    "msg": "MODULE FAILURE",
    "rc": 127
}
~~~

So apparently the aws instance ( ubuntu ) doesn't has python installed !. This is mandatory for ansible to work.

The process of creating and provisioning the complete infrastructure could look as follows:

Run the Terraform template to create servers and populate the inventory file
Run the Ansible playbook to configure all instances in all groups



------
With remote-exec in the application module, it is possible to install python:
~~~
resource "aws_instance" "app-server" {
  ami                    = "${data.aws_ami.app-ami.id}"
  instance_type          = "${lookup(var.instance_type, var.environment)}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${concat(var.extra_sgs, aws_security_group.allow_http.*.id)}"]
  user_data              = "${data.template_file.user_data.rendered}"
  key_name               = "${var.key_name}"

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > inventory" #Inside provisioners (and only inside provisioners) we can use a special keyword self to access attributes of a resource being provisioned
  }

  provisioner "remote-exec" {
    connection {
      user        = "ubuntu"
      private_key = "${file("/home/rob/.ssh/ecskeypair.pem")}" # this must be private key ( so not public key as in the var ${var.key_name})
    }

    inline = [
      "sudo apt-get -y install python"   # need to do taint for this addition : s$ terraform taint -module=appservermodule  aws_instance.app-server

    ]
  }

  tags {
    Name = "${var.name}"
  }
~~~

After this is done,  the ansible command is possible:
~~~
ansible all --private-key=~/.ssh/ecskeypair.pem -i inventory -a  " cat /etc/hosts " -u ubuntu
The authenticity of host '3.120.225.204 (3.120.225.204)' can't be established.
ECDSA key fingerprint is SHA256:SetEA6BcmIMDA2nvTXd/dK3UrlTpeo7T/dWzz583T6M.
Are you sure you want to continue connecting (yes/no)? yes
3.120.225.204 | SUCCESS | rc=0 >>
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
~~~


#Uploading files with a file provisioner

A file provisioner simply uploads a file to the server. It's a perfect way to upload configuration files, certificates, and so on. Create a new file named setup.pp in the ./modules/application/ folder with the following content:
~~~
host { 'repository':
  ip => '10.24.45.127',
}
~~~
One question that could be raised is: why would I use provisioners instead of cloud-init? This is a valid question, and there is exactly one big reason to use provisioners: dependency management inside Terraform. If you use cloud-init, then there is no way to order the creation of different resources inside the Terraform template, simply because Terraform has no idea when cloud-init has finished its job.
- - - -
So far, all provisioners you have learned *are meant to be used with one resource*, and all of them are impossible to rerun without recreating the resource it provisions. In this situation, null_resource is our friend.
