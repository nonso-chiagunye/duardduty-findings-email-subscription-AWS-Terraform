
provider "aws" {
    region = var.AWS_REGION 
}

# Create SNS Topic
resource "aws_sns_topic" "guardduty_sns" {
  name = "guardduty_sns"
}

# Create SNS Topic Subscription with email as protocol and specify target email address
resource "aws_sns_topic_subscription" "guardduty_sns_subscription" {
  topic_arn = aws_sns_topic.guardduty_sns.arn 
  protocol  = "email"
  endpoint  = var.EMAIL_ADDRESS 
}

# Create CloudWatch event rule for GuardDuty finding
resource "aws_cloudwatch_event_rule" "guardduty_event_rule" {
  name        = "guardduty_event_rule"
  description = "Create CloudWatch Event for GuardDuty Findings"

  event_pattern = jsonencode({
    detail-type = [
      "GuardDuty Finding"
    ],
    source = [
        "aws.guardduty"
    ]
  })
}

# Use the SNS Topic created above as CloudWatch event target
resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.guardduty_event_rule.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.guardduty_sns.arn
}

