# Automating Scout Suite Security Scans for AWS

**CODE IN THIS REPOSITORY IS PROVIDED FOR DEMONSTRATION PURPOSES ONLY, USE AT YOUR OWN RISK.**

## Background

See my series of blog posts for more details:

* [Part 1 - Automating Scout Suite Scans for AWS](https://airman604.medium.com/automating-scout-suite-scans-for-aws-ef65ec028bae)
* [Part 2 - Deploying Scout Suite Automation to AWS Using CDK](https://airman604.medium.com/deploying-scout-suite-automation-to-aws-using-cdk-ebc39840dbb4)

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

TBD
