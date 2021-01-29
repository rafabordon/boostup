variable "application" {
}

variable "environment" {
}

variable "number_webservers" {
  default = 2
}

variable "ami" {
  default = "ami-00ddb0e5626798373" 
}

variable "instance_type" {
  default = "t3.small"
}

variable "webserver_internal" {
  default = false
}

variable "webserver_idle_timeout" {
  default = 10
}

variable "webserver_connection_draining" {
  default = true
}

variable "webserver_connection_draining_timeout" {
  default = 60
}

variable "lb_port" {
  default = 80
}

variable "lb_protocol" {
  default = "TCP"
}

variable "lb_backend_port" {
  default = "5000"
}

variable "lb_backend_protocol" {
  default = "TCP"
}

variable "webserver_health_check_interval" {
  default = 15
}

variable "webserver_health_check_healthy_threshold" {
  default = 2
}

variable "webserver_health_check_unhealthy_threshold" {
  default = 4
}

variable "webserver_health_check_timeout" {
  default = 10
}

variable "my_ip" {}