import boto3
import os
import json

dynamodb = boto3.client('dynamodb')
sqs = boto3.client('sqs')
SQS_QUEUE=os.environ("SQS_QUEUE")

def lambda_handler(event, context):
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            new_image = record['dynamodb']['NewImage']
            print(new_image)
            notification_id = new_image['id']['N']
            notification_type = new_image['notification_type']['S']
            # Extract other attributes as needed

            # Forward the message to SQS
            sqs.send_message(
                QueueUrl=SQS_QUEUE,
                MessageBody=json.dumps({
                    'notification_id': notification_id,
                    'notification_type': notification_type,
                    # Add other attributes
                })
            )
