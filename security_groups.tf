###ALB SG#####
resource "aws_security_group" "alb_sg" {
  name        = "${var.cust_name}-alb-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for Application Load Balancer"

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from internet"
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

  tags = merge(local.tags, tomap({ "Name" = "${var.cust_name}-alb-sg" }))
}

###APP EC2 SG#####
resource "aws_security_group" "app_sg" {
  name        = "${var.cust_name}-app-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for app EC2 instances"

  ingress {
    description     = "Allow inbound from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [ingress]
  }

  tags = merge(local.tags, tomap({ "Name" = "${var.cust_name}-app-sg" }))
}
