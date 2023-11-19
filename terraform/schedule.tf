# EventBridge schedule
module "scout_scan_schedule" {
  # use eventbridge Terraform module
  source = "terraform-aws-modules/eventbridge/aws"

  # default bus must be used for scheduled events
  create_bus = false

  rules = {
    scout_scan = {
      description = "scout-scan-daily"
      # daily 10am - time is in UTC
      schedule_expression = "cron(0 10 * * ? *)"
    }
  }

  # target is scanner Lambda function
  targets = {
    scout_scan = [
      {
        name = "scout-scan-daily"
        arn  = module.scout_scan_lambda.lambda_function_arn
      }
    ]
  }
}