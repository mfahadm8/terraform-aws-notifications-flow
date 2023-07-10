import boto3
import os
import json

dynamodb = boto3.client('dynamodb')
sqs = boto3.client("sqs")

DB_TABLE=os.environ.get("DB_TABLE")
DLQ_QUEUE=os.environ.get("DLQ_QUEUE")

def handler(event, context):
    print(event)

    for record in event['Records']:
        notification_id = json.loads(record['body'])["id"]
        
        # Update DynamoDB record with delivery_status as SEND_FAIL
        dynamodb.update_item(
            TableName=DB_TABLE,
            Key={
                'id': {'S': notification_id}
            },
            UpdateExpression='SET delivery_status = :status',
            ExpressionAttributeValues={
                ':status': {'S': 'SEND_FAIL'}
            }
        )

        sqs.delete_message(
            QueueUrl=DLQ_QUEUE,
            ReceiptHandle=record['receiptHandle']
        )

