# Automating Scout Suite Security Scans for AWS

**CODE IN THIS REPOSITORY IS PROVIDED FOR DEMONSTRATION PURPOSES ONLY, USE AT YOUR OWN RISK.**

## Background

See my series of blog posts for more details:

* [Automating Scout Suite Scans for AWS - Part 1](https://airman604.medium.com/automating-scout-suite-scans-for-aws-ef65ec028bae)
* [Automating Scout Suite Scans for AWS - Part 2](about:TBD)
* [Automating Scout Suite Scans for AWS - Part 3](about:TBD)

## Architecture

![AWS scan automation architecture](aws_scan_automation.png)

## Deploying using CDK

Pre-requisites:

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)
* [Node](https://nodejs.org/en/learn/getting-started/how-to-install-nodejs)
* [AWS CDK](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html#getting_started_install)
* [Docker](https://docs.docker.com/engine/install/)

As an alternative you can open this repository in **VS Code** with **Dev Containers** module installed,
and click **Reopen in Container**. The included development container configuration installs all the needed
tools (you still need Docker though).

```bash
# clone the rpository
git clone https://github.com/airman604/aws-scan-automation.git
cd aws-scan-automation

# before continuing, configure AWS CLI with your credentials
aws configure

# bootstrap CDK
# note: you can add --profile AWS_PROFILE to cdk all subsequent cdk
#       commands to use specific AWS CLI profile
cd cdk
cdk bootstrap

# deploy:
#  - replace the parameter value with your email address
#  - once the stack is deployed, you will get a verification email
#     from AWS SES, click on the link to confirm your ownership of
#     the email address
cdk deploy --parameters scanResultNotificationEmail=YOUR_EMAIL_HERE

# if at a later point of time you want to delete all the
# deployed resources:
cdk destroy
```

## Deploying Using Terraform

Pre-requisites:

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [Docker](https://docs.docker.com/engine/install/)

As an alternative you can open this repository in **VS Code** with **Dev Containers** module installed,
and click **Reopen in Container**. The included development container configuration installs all the needed
tools (you still need Docker though).

```bash
# clone the rpository
git clone https://github.com/airman604/aws-scan-automation.git
cd aws-scan-automation

# before continuing, configure AWS CLI with your credentials
aws configure

# download Terraform providers and modules
# note: you can set AWS_PROFILE environment variable to use specific AWS CLI profile
cd terraform
terraform init

# deploy:
#  - Terraform will ask for the email address for the notifier Lambda.
#  - You can add `notification_recipient` parameter to terraform.tfvars file
#     so you don't need to be entering the email address every time you run Terraform.
#  - once the resources are deployed, you will get a verification email
#     from AWS SES, click on the link to confirm your ownership of
#     the email address
terraform apply

# if at a later point of time you want to delete all the
# deployed resources (note that Terraform will refuse to delete
# the S3 bucket if it's not empty):
terraform destroy
```