import os


os.environ['DB_TABLE'] = 'notification-table'
os.environ['DLQ_QUEUE'] = 'https://sqs.us-east-1.amazonaws.com/188775091215/notification_dlq'
os.environ['NOTIFICATION_SES_TEMPLATE'] = 'NotificationSESTemplate'
os.environ['SNS_TOPIC'] = 'arn:aws:sns:us-east-1:188775091215:notification_sns'
os.environ['SQS_QUEUE'] = 'https://sqs.us-east-1.amazonaws.com/188775091215/notification_queue'

from index import handler

handler(
{'Records': [{'messageId': 'aa3702e5-fef8-4afa-a9e6-20a5d3a98cb5', 'receiptHandle': 'AQEBLgPgGbEigE62yLtDRhRm/VpdOXsE4TB9GJyeQvla6iaUDrERS2/ncGk81BK0VbZy62hgCyW2+0SHoBDC5YPVpspjO8JnPRYO27wVElHroIK5hROsG3gqsYP1DQqiAA1vcePdthMm3OFux8UBnXR7LcC8wE44G4LEha21WeYfTAVlS/Au2cLqVQ1XnxWy5vYRq3lA0NYG52xIcqhwTDiOzxtJ4f+unphg+VAUUTi7/yfdZRN/abAOdfPPt7Dp2dO4cFV+/5vqUZ9jvSDnbTx8IT3CSx5dDdf29VwktwRMKJWB2AIHg8yGGewoAQ/eo08GN/ey+tBGAkDCbU0jH634fvHbEDTK7QDjASy8KtsrsVv3CMyYlNVbYn6Z87m8V+qqtrVDqyQekd/rJyDF5P4PCA==', 'body': '{"notification_type": "EMAIL", "read_date_time": "1688769070", "to_name": "Fahad", "to_email_address": "mfahadm8@gmail.com", "id": "8"}', 'attributes': {'ApproximateReceiveCount': '1', 'AWSTraceHeader': 'Root=1-64aa991e-4834211e308562dc2b1d88a0;Parent=7a6dcf21346c41c5;Sampled=0;Lineage=18c168d2:0', 'SentTimestamp': '1688901918414', 'SenderId': 'AROASX467JQHY4QHDAHMW:NotificationForwarder', 'ApproximateFirstReceiveTimestamp': '1688901918418'}, 'messageAttributes': {}, 'md5OfBody': '0c3002c85b6ae773e17fe5709e7e3cf3', 'eventSource': 'aws:sqs', 'eventSourceARN': 'arn:aws:sqs:us-east-1:188775091215:notification_queue', 'awsRegion': 'us-east-1'}]}
    ,{})