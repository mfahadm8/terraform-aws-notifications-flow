import boto3
import json 
import os
import datetime
dynamodb = boto3.client('dynamodb')

ses = boto3.client('ses')
sqs = boto3.client('sqs')
sns = boto3.client('sns')
SQS_QUEUE=os.environ.get("SQS_QUEUE")
DLQ_QUEUE=os.environ.get("DLQ_QUEUE")
SNS_TOPIC_ARN=os.environ.get("SNS_TOPIC")
SENDER_EMAIL=os.environ.get("SENDER_EMAIL")

def handler(event, context):
    print(event)
    for record in event['Records']:
        message = dict(json.loads(record['body']))
        notification_id = message['id']
        notification_type = message['notification_type']
        to_name=message["to_name"]

        if notification_type == 'SMS':
            mobile_no =  message['mobile_no']
            sms_message = message['sms_message']
            # Send SMS using SNS
            smsattrs = {
                'AWS.SNS.SMS.SenderID': { 'DataType': 'String', 'StringValue': 'Suraj' },
                'AWS.SNS.SMS.SMSType': { 'DataType': 'String', 'StringValue': 'Transactional'}
            }
            sns.publish(
                PhoneNumber=mobile_no,
                Message=f"Hi, {to_name},\n"+sms_message,
                MessageAttributes = smsattrs

            )
        elif notification_type == 'EMAIL':
            to_email_address = message['to_email_address']
            email_template = message['email_template']
            template_data=get_template_data(email_template,message)
            response = ses.send_templated_email(
                Source=SENDER_EMAIL,
                Destination={
                    'ToAddresses': [to_email_address],
                },
                ReplyToAddresses=[SENDER_EMAIL],
                Template=email_template,
                TemplateData=template_data
            )
            print(response)

        # Update DynamoDB record with delivery_status as SENT
        timestamp = str(int(datetime.datetime.now().timestamp()*1000))  # Get current date and time
        dynamodb.update_item(
            TableName=os.environ['DB_TABLE'],
            Key={
                'id': {'S': notification_id}
            },
            UpdateExpression='SET delivery_status = :status, delivery_timestamp = :timestamp',
            ExpressionAttributeValues={
                ':status': {'S': 'SENT'},
                ':timestamp': {'S': timestamp}
            }
        )
        
        # Delete the processed message from SQS Queue 2
        sqs.delete_message(
            QueueUrl=SQS_QUEUE,
            ReceiptHandle=record['receiptHandle']
        )

def get_template_data(email_template_name,message):
    if email_template_name == "NotificationSESTemplate":
        to_name=message["to_name"]
        favoriteanimal=message["favoriteanimal"]
        template_data = json.dumps({
            'name': to_name,
            'favoriteanimal': favoriteanimal
        })
        return template_data
    
    elif email_template_name == "NotificationUserPasswordChangeRequest":
        to_name=message["to_name"]
        verification_code=message["verification_code"]
        template_data = json.dumps({
            'name': to_name,
            'verification_code': verification_code
        })
        return template_data
    
    elif email_template_name == "NotificationNewUserSignup":
        to_name=message["to_name"]
        template_data = json.dumps({
            'name': to_name
        })
        return template_data