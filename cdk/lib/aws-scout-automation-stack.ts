import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as s3n from 'aws-cdk-lib/aws-s3-notifications';
import * as sns from 'aws-cdk-lib/aws-sns';
import * as subscriptions from 'aws-cdk-lib/aws-sns-subscriptions';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as events from "aws-cdk-lib/aws-events";
import * as targets from "aws-cdk-lib/aws-events-targets";
import * as ecr_assets from "aws-cdk-lib/aws-ecr-assets";

export class AwsScoutAutomationStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // This code is provided as-is and is not production ready.
    // Use at your own risk!

    // email address to send notifications to
    const notificationEmail = new cdk.CfnParameter(this, "scanResultNotificationEmail", {
      type: "String",
      description: "Where to send email notifications when new scan report is available."
    });

    // path in S3 for scan reports
    const scoutReportPrefix = "scout-reports/" + this.account;
    const scoutReportPrefixPattern = scoutReportPrefix + "/*";

    // S3 bucket where the scan results are saved
    const s3Bucket = new s3.Bucket(this, "ScoutResultsBucket");

    // SNS Topic for scan report notifications
    const snsTopic = new sns.Topic(this, 'ScoutNotifications');
    snsTopic.addSubscription(new subscriptions.EmailSubscription(notificationEmail.valueAsString));

    // Lambda that will be invoked when new object is uploaded to S3
    // and will send notification emails through SNS
    const notificationLambda = new lambda.Function(this, "NotificationLambda", {
      runtime: lambda.Runtime.PYTHON_3_11,
      handler: 'index.handler',
      code: lambda.Code.fromAsset("../lambda-notifications"),
      environment: {
        "SNS_TOPIC": snsTopic.topicArn
      }
    });

    // add permissions for Lambda to send emails through SNS notifications
    snsTopic.grantPublish(notificationLambda);

    // invoke the lambda on new object upload
    s3Bucket.addObjectCreatedNotification(new s3n.LambdaDestination(notificationLambda), {
      prefix: scoutReportPrefix
    });
    // add permissions for Lambda to read from S3
    s3Bucket.grantRead(notificationLambda, scoutReportPrefixPattern);

    // Lambda that runs Scout Suite scans
    const scoutLambda = new lambda.Function(this, "ScoutLambda", {
      runtime: lambda.Runtime.FROM_IMAGE,
      code: lambda.Code.fromAssetImage("../lambda-scout", {
        // this is needed when running on Apple silicon
        platform: ecr_assets.Platform.LINUX_AMD64
      }),
      handler: lambda.Handler.FROM_IMAGE,
      memorySize: 2048,
      timeout: cdk.Duration.minutes(15),
      environment: {
        "S3_BUCKET": s3Bucket.bucketName,
        "S3_PREFIX": scoutReportPrefix
      }
    });
    // give scanning Lambda appropriate permissions
    // see: https://github.com/nccgroup/ScoutSuite/wiki/Amazon-Web-Services#permissions
    scoutLambda.role?.addManagedPolicy(iam.ManagedPolicy.fromAwsManagedPolicyName("SecurityAudit"));
    scoutLambda.role?.addManagedPolicy(iam.ManagedPolicy.fromAwsManagedPolicyName("ReadOnlyAccess"));
    // and access to S3 to upload reports
    s3Bucket.grantPut(scoutLambda, scoutReportPrefixPattern);

    // run the scanner Lambda daily
    const eventRule = new events.Rule(this, "DailyScoutScan", {
      // 10:00am - time in UTC!
      schedule: events.Schedule.cron({ minute: '0', hour: '10' }),
    });
    eventRule.addTarget(new targets.LambdaFunction(scoutLambda));
  }
}
