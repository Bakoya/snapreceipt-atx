# S3 bucket for ALB access logs
resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.cust_name}-${var.env}-alb-access-logs"
  tags   = merge(var.tags, tomap({ "Name" = "${var.cust_name}-${var.env}-alb-access-logs" }))
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    id     = "expire-old-logs"
    status = "Enabled"
    filter {}
    expiration {
      days = 90
    }
  }
}

# eu-west-1 Elastic Load Balancing service account, per AWS documentation
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ELBAccessLogsWrite"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::156460612806:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/${var.cust_name}-alb-access-log/AWSLogs/${var.account_id}/*"
      }
    ]
  })
}

resource "aws_lb" "main" {
  name               = "${var.cust_name}-alb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  idle_timeout       = 120

  security_groups = [var.alb_sg_id]
  subnets         = var.public_subnet_ids

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "${var.cust_name}-alb-access-log"
    enabled = true
  }

  enable_deletion_protection = var.env == "prod" ? true : false

  tags = merge(var.tags, tomap({ "Name" = "${var.cust_name}-alb-${var.env}" }))

  depends_on = [aws_s3_bucket_policy.alb_logs]
}

# No ECS services exist yet - default actions are placeholders until the first
# service adds its own listener rule (see billsng-ecs modules/alb-listener-rule).
resource "aws_lb_listener" "http" {
  count             = var.certificate_arn == "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No application configured"
      status_code  = "404"
    }
  }

  tags = merge(var.tags, tomap({ "Name" = "${var.cust_name}-alb-listener-80-${var.env}" }))
}

resource "aws_lb_listener" "http_redirect" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(var.tags, tomap({ "Name" = "${var.cust_name}-alb-listener-80-redirect-${var.env}" }))
}

resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No application configured"
      status_code  = "404"
    }
  }

  tags = merge(var.tags, tomap({ "Name" = "${var.cust_name}-alb-listener-443-${var.env}" }))
}

# CodeDeploy blue/green test-traffic listeners. Mirror the prod listener on
# each port (80<->8080, 443<->8443) so a service opting into blue/green can
# route its "green" target group here during a deployment shift.
resource "aws_lb_listener" "http_test" {
  count             = var.certificate_arn == "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No application configured"
      status_code  = "404"
    }
  }

  tags = merge(var.tags, tomap({ "Name" = "${var.cust_name}-alb-listener-8080-${var.env}" }))
}

resource "aws_lb_listener" "https_test" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 8443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No application configured"
      status_code  = "404"
    }
  }

  tags = merge(var.tags, tomap({ "Name" = "${var.cust_name}-alb-listener-8443-${var.env}" }))
}
