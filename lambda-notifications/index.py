import boto3
from botocore.exceptions import ClientError

import os
# import logging

# s3 = boto3.client("s3")

def handler(event: dict, context):
    for r in event["Records"]:
        if r["eventSource"] != "aws:s3":
            print(f"ERROR: unknown event source: {r['eventSource']}, skipping")
            continue

        bucket = r["s3"]["bucket"]["name"]
        object_key = r["s3"]["object"]["key"]
        sendEmail(bucket, object_key)

def sendEmail(s3_bucket: str, s3_object_key: str):
    SENDER = os.environ["SENDER"]
    RECIPIENT = os.environ["RECIPIENT"]
    SUBJECT = "ScoutSuite scan results"
    aws_region = os.environ["AWS_REGION"]
             
    presigned_url = create_presigned_url(s3_bucket, s3_object_key)
    s3_console_link = f"https://s3.console.aws.amazon.com/s3/object/{s3_bucket}?region={aws_region}&prefix={s3_object_key}"

    BODY_TEXT = ("New ScoutSuite scan results are available:\r\n\r\n"
                 f"Direct download link (expires in 24 hours): {presigned_url}\r\n\r\n"
                 f"S3 object link in AWS console (use your AWS credentials to access): {s3_console_link}"
                )

    client = boto3.client('ses')

    # Try to send the email.
    try:
        #Provide the contents of the email.
        response = client.send_email(
            Destination={
                'ToAddresses': [
                    RECIPIENT,
                ],
            },
            Message={
                'Body': {
                    'Text': {
                        'Charset': 'UTF-8',
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Charset': 'UTF-8',
                    'Data': SUBJECT,
                },
            },
            Source=SENDER
        )
    except ClientError as e:
        # Display an error if something goes wrong.	
        print(f"Error while sending email: {e.response['Error']['Message']}")
    else:
        print(f"Email sent for s3://{s3_bucket}/{s3_object_key}! Message ID: {response['MessageId']}"),

def create_presigned_url(bucket_name, object_name, expiration=24*60*60):
    """Generate a presigned URL to share an S3 object

    :param bucket_name: string
    :param object_name: string
    :param expiration: Time in seconds for the presigned URL to remain valid (default 24 hours)
    :return: Presigned URL as string. If error, returns None.
    """

    # Generate a presigned URL for the S3 object
    s3_client = boto3.client('s3')
    try:
        response = s3_client.generate_presigned_url('get_object',
                                                    Params={'Bucket': bucket_name,
                                                            'Key': object_name},
                                                    ExpiresIn=expiration)
    except ClientError as e:
        print(f"Error while generating pre-signed URL: {e.response['Error']['Message']}")
        return None

    # The response contains the presigned URL
    return response