import boto3
import os
import json
from decimal import Decimal
from boto3.dynamodb.types import TypeDeserializer

dynamodb = boto3.client('dynamodb')
sqs = boto3.client('sqs')
SQS_QUEUE=os.environ.get("SQS_QUEUE")

deserializer = TypeDeserializer()
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, Decimal):
            return str(o)
        return super(DecimalEncoder, self).default(o)
    

def handler(event, context):
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            new_image = record['dynamodb']['NewImage']
            print(new_image)
            deserialized_document = {k: deserializer.deserialize(v) for k, v in new_image.items()}

            # Forward the message to SQS
            sqs.send_message(
                QueueUrl=SQS_QUEUE,
                MessageBody=json.dumps(deserialized_document,cls=DecimalEncoder)
            )
