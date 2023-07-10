# Installation
- Be sure to change the variable values in `variables.tf` as per requirements
    - `region` - AWS REGION
    - `sns_sender_email` - The EMAIL Address that has to be provided as Source/Sender while sending EMAIL notifications

## Installation Command
The following command deploys the entire infrastructure on cloud including database and everything. The flow for triggers every new notification id pushed to dynamodb and not on the existing db entry modificatoin.
```bash
terraform apply
```

## EMAIL NOTIFICATIONS

The SES account is currently under sandbox environemnt, To test EMAIL type notificaition, go to ses console and add testing emails to verified entities.
Now go to DynamoDb, and create a sample notification entry with paramter. 
```json
{
    "id":"1",
    "to_name":"Name",
    "to_email_address":"testemail@gmail.com",
    "notification_type":"EMAIL"

}
```
Alternatively, you can use the script packaged with the code as stated below but one needs to modify the id, email and name in script as well
## SMS NOTIFICATIONS

For testing SMS type notifications, go to SNS Console, you need to do two things

1. Add testing destination phone number. 
2. Edit Text messaging preferences and select Transactional under Default Message Type.

Please note, that the SNS Text Messages Account is under sanbox by default and it has various limitations applied

Now go to DynamoDb, and create a sample notification entry with paramters
```json
{
    "id":"2",
    "mobile_no":"+61MMMMMMM",
    "to_name":"Name",
    "sms_message":"Some text message",
    "notification_type":"SMS"

}
```
Alternatively, you can use the script packaged with the code as stated below but one needs to modify the id, mobile_no and name in script as well.

# TESTING
To test the working of email and sms flow, I have written down scripts with sample json data under `tests` folder.
Go to `tests` folder, and run the following command. Be sure to change the email.json and sms.json file.

### FOR EMAIL
```bash
dynamo_push.sh email.json
``` 
- Pushes data to dynamodb with required email attributes that trigger the email flow

### For SMS
```bash
dynamo_push.sh sms.json
```
- Pushes data to dynamodb with required SMS attributes
