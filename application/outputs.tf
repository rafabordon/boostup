output "elb_public_dns" {
  value = aws_elb.webserver.dns_name
}

output "ssh_private_key" {
  value = data.template_file.private_key.rendered
}