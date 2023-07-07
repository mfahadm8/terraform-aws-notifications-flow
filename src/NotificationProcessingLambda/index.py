import boto3
import json 
import os

dynamodb = boto3.client('dynamodb')
sns = boto3.client('sns')
ses = boto3.client('ses')
sqs = boto3.client('sqs')

SQS_QUEUE=os.environ("SQS_QUEUE")
DLQ_QUEUE=os.environ("DLQ_QUEUE")
SNS_TOPIC_ARN=os.environ("SNS_TOPIC_ARN")
NOTIFICATION_SES_TEMPLATE=os.environ("NOTIFICATION_SES_TEMPLATE")

def lambda_handler(event, context):
    print(event)
    for record in event['Records']:
        message = json.loads(record['body'])
        notification_id = message['notification_id']
        notification_type = message['notification_type']
        # Extract other attributes as needed

        if notification_type == 'SMS':
            mobile_no = message['mobile_no']
            sms_message = message['sms_message']
            # Send SMS using SNS
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                PhoneNumber=mobile_no,
                Message=sms_message
            )
        elif notification_type == 'EMAIL':
            to_email_address = message['to_email_address']
            template_data = json.dumps({
                'name': 'Alejandro',
                'favoriteanimal': 'alligator'
            })
            # Send email using SES
            ses.send_templated_email(
                Source='Mary Major <mary.major@example.com>',
                Template='MyTemplate',
                ConfigurationSetName='ConfigSet',
                Destination={
                    'ToAddresses': [to_email_address]
                },
                TemplateData=template_data
            )

        # Update DynamoDB record with delivery_status as SENT
        dynamodb.update_item(
            TableName=os.environ['DB_TABLE'],
            Key={
                'id': {'N': notification_id}
            },
            UpdateExpression='SET delivery_status = :status',
            ExpressionAttributeValues={
                ':status': {'S': 'SENT'}
            }
        )
        
        # Delete the processed message from SQS Queue 2
        sqs.delete_message(
            QueueUrl=SQS_QUEUE,
            ReceiptHandle=record['receiptHandle']
        )
