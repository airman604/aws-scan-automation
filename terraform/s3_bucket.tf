# bucket to store scan reports
resource "aws_s3_bucket" "s3_report_bucket" {
  # bucket name - random identifier will be added at the end
  bucket_prefix = "scout-scan-reports-"
}

# configure notification Lambda invocation when new report is uploaded to the S3 bucket
# Lambda resources are defined in notifications.tf
module "report_notifications" {
  # use notification sub-module of s3-bucket module
  source = "terraform-aws-modules/s3-bucket/aws//modules/notification"

  # bucket defined earlier
  bucket = aws_s3_bucket.s3_report_bucket.id

  # notification target is Lambda that will send emails using SES
  lambda_notifications = {
    scout_report_notifications = {
      function_arn  = module.notification_lambda.lambda_function_arn
      function_name = module.notification_lambda.lambda_function_name
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "${local.s3_prefix}"
      filter_suffix = ".tar.gz"
    }
  }
}
