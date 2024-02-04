module "notifications_sns" {
  source  = "terraform-aws-modules/sns/aws"

  name = "scout-notifications-topic"
  subscriptions = {
    email = {
      protocol = "email"
      endpoint = var.notification_recipient
    }
  }
}

# Lambda that will send SNS notifications when new scan reports are uploaded to S3
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
    sns_publish = {
      effect = "Allow"
      actions = [
        "sns:Publish"
      ]
      resources = [
        module.notifications_sns.topic_arn
      ]
    }
  }

  # Lambda gets sender and recipient email addresses from environment
  environment_variables = {
    SNS_TOPIC    = module.notifications_sns.topic_arn
  }
}
