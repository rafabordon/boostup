output "elb_public_dns" {
  value = aws_elb.webserver.dns_name
}

output "webservers" {
  value = aws_instance.webserver.*.public_ip
}

output "mongo" {
  value = aws_instance.mongodb.public_ip
}

output "ssh_private_key" {
  value = data.template_file.private_key.rendered
}
