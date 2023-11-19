# SES identity (email) to send notifications to
resource "aws_sesv2_email_identity" "notification_recipient" {
  email_identity = var.notification_recipient
}

# Lambda that will send SES notifications when new scan reports are uploaded to S3
module "notification_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "scout-notifications"
  handler       = "index.handler"
  runtime       = "python3.11"

  # Lambda function source code location
  source_path = "../lambda-notifications"

  # add permissions for generation of S3 pre-signed URLs and sending emails
  attach_policy_statements = true
  policy_statements = {
    s3_read = {
      effect = "Allow"
      actions = [
        "s3:GetObject"
      ]
      resources = ["${aws_s3_bucket.s3_report_bucket.arn}/${local.s3_prefix}/*"]
    },
    ses_send = {
      effect = "Allow"
      actions = [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ]
      resources = [
        "${aws_sesv2_email_identity.notification_recipient.arn}"
      ]
    }
  }

  # Lambda gets sender and recipient email addresses from environment
  environment_variables = {
    SENDER    = var.notification_recipient
    RECIPIENT = var.notification_recipient
  }
}
