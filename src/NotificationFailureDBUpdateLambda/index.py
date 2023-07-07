import boto3
import os

dynamodb = boto3.client('dynamodb')
sqs = boto3.client("sqs")

DB_TABLE=os.environ("DB_TABLE")
DLQ_QUEUE=os.environ("DLQ_QUEUE")

def lambda_handler(event, context):
    print(event)

    for record in event['Records']:
        notification_id = record['messageAttributes']['notification_id']['stringValue']
        
        # Update DynamoDB record with delivery_status as SEND_FAIL
        dynamodb.update_item(
            TableName=DB_TABLE,
            Key={
                'id': {'N': notification_id}
            },
            UpdateExpression='SET delivery_status = :status',
            ExpressionAttributeValues={
                ':status': {'S': 'SEND_FAIL'}
            }
        )
                # Delete the processed message from SQS Queue 2
        sqs.delete_message(
            QueueUrl=DLQ_QUEUE,
            ReceiptHandle=record['receiptHandle']
        )

