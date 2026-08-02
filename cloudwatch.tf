# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.cust_name}-${var.env}-infrastructure"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title = "VPC Network - Bytes In/Out"
          metrics = [
            [{ expression = "SELECT SUM(BytesInFromSource) FROM SCHEMA(\"AWS/NATGateway\", NatGatewayId)", label = "Bytes In", id = "e1" }],
            [{ expression = "SELECT SUM(BytesOutToDestination) FROM SCHEMA(\"AWS/NATGateway\", NatGatewayId)", label = "Bytes Out", id = "e2" }]
          ]
          period = 300
          region = var.region
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          title  = "CloudTrail - Recent API Activity"
          query  = "SOURCE '/aws/cloudtrail/${var.cust_name}-${var.env}' | fields @timestamp, eventName, userIdentity.arn, sourceIPAddress | sort @timestamp desc | limit 20"
          region = var.region
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 24
        height = 6
        properties = {
          title  = "VPC Flow Logs - Rejected Traffic"
          query  = "SOURCE '/aws/vpc-flow-logs/${var.cust_name}-${var.env}' | filter action = 'REJECT' | stats count(*) as rejectedCount by srcAddr, dstAddr, dstPort | sort rejectedCount desc | limit 20"
          region = var.region
        }
      }
    ]
  })
}

# NOTE: the "CloudTrail - Recent API Activity" widget above will show no
# data once the local trail/log group is removed (see cloudtrail_alarms.tf.disabled
# and cloudtrail.tf.disabled) - left as-is since it wasn't asked to be removed.

# SNS topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.cust_name}-${var.env}-security-alerts"
  tags = local.tags
}
