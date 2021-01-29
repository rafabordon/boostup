# ---------------------------------------------------------------------------------------------------------------------
# Create ELB webserver
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_elb" "webserver" {
  name = "${var.application}-${var.environment}-elb"

  internal                    = var.webserver_internal
  idle_timeout                = var.webserver_idle_timeout
  connection_draining         = var.webserver_connection_draining
  connection_draining_timeout = var.webserver_connection_draining_timeout

  security_groups = [aws_security_group.webserver-elb.id]
  subnets         = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  listener {
    lb_port           = var.lb_port
    lb_protocol       = var.lb_protocol
    instance_port     = var.lb_backend_port
    instance_protocol = var.lb_backend_protocol
  }

  health_check {
    target              = "HTTP:5000/"
    interval            = var.webserver_health_check_interval
    healthy_threshold   = var.webserver_health_check_healthy_threshold
    unhealthy_threshold = var.webserver_health_check_unhealthy_threshold
    timeout             = var.webserver_health_check_timeout
  }

  tags = {
    name = "${var.application}-${var.environment}-elb"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ELB securty group
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "webserver-elb" {
  name        = "${var.application}-${var.environment}-elb"
  description = "Security group for the ${var.application} - ${var.environment} ELB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
}

resource "aws_security_group_rule" "allow_inbound_api_calls" {
  type                     = "ingress"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.webserver-elb.id
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound_webserver" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver-elb.id
}

