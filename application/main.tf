# ---------------------------------------------------------------------------------------------------------------------
# WebServer instances setup
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user-data" {
  template = file("${path.module}/templates/user_data.tpl")
}

data "template_file" "public_key" {
  template = file("${path.module}/files/id_rsa.pub")
}

data "template_file" "private_key" {
  template = file("${path.module}/files/id_rsa")
}

data "template_file" "dockerfile" {
  template = file("${path.module}/files/Dockerfile")
}

resource "aws_key_pair" "webserver" {
  key_name   = "${var.application}-${var.environment}"
  public_key = data.template_file.public_key.rendered
}

resource "aws_instance" "webserver" {
  count         = var.number_webservers
  ami           = var.ami
  instance_type = var.instance_type
  monitoring    = false
  key_name      = aws_key_pair.webserver.key_name
  associate_public_ip_address = true
  subnet_id = element(data.terraform_remote_state.vpc.outputs.public_subnet_ids,0)

  user_data              = data.template_file.user-data.rendered
  vpc_security_group_ids = [aws_security_group.webserver.id]

  provisioner "file" {

    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = data.template_file.private_key.rendered
    }

    content     = data.template_file.dockerfile.rendered
    destination = "/tmp/Dockerfile"
  }

  provisioner "remote-exec" {

    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = data.template_file.private_key.rendered
    }

    inline = [
      "sleep 180",
      "cd /tmp",
      "git clone https://github.com/sarathlalsaseendran/FlaskWithMongoDB.git",
      "sudo docker build --build-arg MONGODB_IP=${aws_instance.mongodb.private_ip} -t webserver:1.0.0 .",
      "sudo docker run --name webserver --rm -p 5000:5000 -dt webserver:1.0.0",
    ]
  }

  provisioner "file" {

    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = data.template_file.private_key.rendered
    }

    content     = file("${path.module}/files/authorized_keys")
    destination = "/tmp/authorized_keys"
  }

provisioner "remote-exec" {

    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = data.template_file.private_key.rendered
    }

    inline = [
      "cd /tmp",
      "sudo cat authorized_keys >> /home/ubuntu/.ssh/authorized_keys"
    ]
  }


  lifecycle {
    ignore_changes = [
      key_name,
      user_data,
    ]
  }

  tags = {
    "Name"        = "${var.application}-${count.index}-${var.environment}"
    "application" = var.application
    "environment" = var.environment
  }
}

resource "aws_security_group" "webserver" {
  name        = "${var.application}-${var.environment}"
  description = "${var.application} - ${var.environment} - SG"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
}

resource "aws_security_group_rule" "allow_webserver_elb" {
  type                     = "ingress"
  from_port                = "5000"
  to_port                  = "5000"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.webserver.id
  source_security_group_id = aws_security_group.webserver-elb.id
}

resource "aws_security_group_rule" "allow_external_ssh" {
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.webserver.id
  cidr_blocks              = [ "${var.my_ip}/32" ]
}

resource "aws_security_group_rule" "allow_webserver_egress" {
  type                     = "egress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  security_group_id        = aws_security_group.webserver.id
  cidr_blocks              = [ "0.0.0.0/0" ]
}

resource "aws_elb_attachment" "webserver" {
  count    = var.number_webservers
  elb      = aws_elb.webserver.id
  instance = element(aws_instance.webserver.*.id, count.index)
}

# ---------------------------------------------------------------------------------------------------------------------
# MongoDB setup
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "mongodb" {
  ami           = var.ami
  instance_type = var.instance_type
  monitoring    = false
  key_name      = aws_key_pair.webserver.key_name
  associate_public_ip_address = true
  subnet_id = element(data.terraform_remote_state.vpc.outputs.public_subnet_ids,0)

  user_data              = data.template_file.user-data.rendered
  vpc_security_group_ids = [aws_security_group.mongodb.id]

  provisioner "remote-exec" {

    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = data.template_file.private_key.rendered
    }

    inline = [
      "sleep 180 && sudo docker run --rm --name mongodb -dt -p 27017:27017 mongo:4.2.12-bionic mongod",
    ]
  }

  lifecycle {
    ignore_changes = [
      key_name,
      user_data,
    ]
  }

  tags = {
    "Name"        = "mongodb-${var.environment}"
    "application" = "mongodb"
    "environment" = var.environment
  }
}

resource "aws_security_group" "mongodb" {
  name        = "mongodb-${var.environment}"
  description = "mongodb - ${var.environment} - SG"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
}

resource "aws_security_group_rule" "allow_mongodb_webserver" {
  type                     = "ingress"
  from_port                = "27017"
  to_port                  = "27017"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mongodb.id
  source_security_group_id = aws_security_group.webserver.id
}

resource "aws_security_group_rule" "allow_mongodb_ssh" {
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mongodb.id
  cidr_blocks              = [ "${var.my_ip}/32" ]
}

resource "aws_security_group_rule" "allow_mongodb_egress" {
  type                     = "egress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  security_group_id        = aws_security_group.mongodb.id
  cidr_blocks              = ["0.0.0.0/0"]
}

