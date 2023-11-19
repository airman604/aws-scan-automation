# ScoutSuite Docker image
module "scout_docker_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  # create ECR repo and push image
  create_ecr_repo = true
  ecr_repo        = "scout-lambda"

  use_image_tag = false # If false, sha of the image will be used as tag

  # path with Dockerfile and context to build the image
  source_path = "../lambda-scout"
  # specify platform to ensure portability of Terraform code
  platform = "linux/amd64"
}

# ScoutSuite Lambda Function that will execute the scans
module "scout_scan_lambda" {
  # use lambda Terraform module
  source = "terraform-aws-modules/lambda/aws"

  function_name = "scout-scanner"

  # allow schedule-based triggers
  allowed_triggers = {
    ScoutScanEventBridgeRule = {
      principal  = "events.amazonaws.com"
      source_arn = module.scout_scan_schedule.eventbridge_rule_arns["scout_scan"]
    }
  }
  # get errors without this, see https://github.com/terraform-aws-modules/terraform-aws-lambda/issues/36
  create_current_version_allowed_triggers = false

  # don't need to create the package - using container image defined above
  create_package = false
  package_type   = "Image"
  # must match image architecture!
  architectures = ["x86_64"]
  image_uri     = module.scout_docker_image.image_uri

  # add permissions for ScoutSuite scans
  attach_policies = true
  policies = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/SecurityAudit"
  ]
  number_of_policies = 2

  # add access to S3 bucket with reports
  attach_policy_statements = true
  policy_statements = {
    s3_write = {
      effect    = "Allow"
      actions   = ["s3:PutObject"]
      resources = ["${aws_s3_bucket.s3_report_bucket.arn}/${local.s3_prefix}/*"]
    }
  }

  # pass parameters to Lambda for report upload location
  environment_variables = {
    S3_BUCKET = aws_s3_bucket.s3_report_bucket.id
    S3_PREFIX = local.s3_prefix
  }

  memory_size = 2048
  # max possible Lambda execution time 15 min
  timeout = 15 * 60
}