import boto3
import json 
import os
os.environ["AWS_REGION"]="ap-southeast-2"

pinpoint = boto3.client('pinpoint')


response=pinpoint.send_messages(
    ApplicationId='40fcb11c8a4e4a4e88b4487cd3402286',

    MessageRequest={
        'Addresses': {
            '+923055629275': {'ChannelType': 'SMS'}
        },
        'MessageConfiguration': {
            'SMSMessage': {
                'Body': "Hi",
                'MessageType': 'PROMOTIONAL'
            }
        }
    }
)
print(response)