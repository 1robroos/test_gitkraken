resource "aws_security_group" "allow_http" {
  name        = "${var.name} allow_http"
  description = "Allow HTTP traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "app-ami" {
  most_recent = true

  #  owners      = ["self"]
  # ubuntu ami account ID
  owners = ["099720109477"]
}

resource "aws_instance" "app-server" {
  ami                    = "${data.aws_ami.app-ami.id}"
  instance_type          = "${lookup(var.instance_type, var.environment)}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${concat(var.extra_sgs, aws_security_group.allow_http.*.id)}"]
  user_data              = "${data.template_file.user_data.rendered}"
  key_name               = "${var.key_name}"

  tags {
    Name = "${var.name}"
  }

  /*Changing user_data normally leads to resource recreation. We don't really want our server to be destroyed when this file changes.
    Let's revise what we learned in previous chapter about life cycle block and tell the instance to ignore changes of user_data: */
  lifecycle {
    ignore_changes = ["user_data"]
  }
}

output "hostname" {
  value = "${aws_instance.app-server.private_dns}"
}

/* Terraform provides the template_file data source, responsible for rendering text templates.
It's really useful for bootstrap scripts, such as the ones you provide to cloud-init.
*/
data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"

  vars {
    packages   = "${var.extra_packages}"
    nameserver = "${var.external_nameserver}"
  }
}
