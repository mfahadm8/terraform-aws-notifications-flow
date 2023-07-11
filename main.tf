provider "aws" {
  region = var.region

}
data "aws_caller_identity" "current" {}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "sqs" {
  source = "./modules/sqs"
}

module "sns" {
  source = "./modules/sns"
}

module "ses" {
  source = "./modules/ses"
}

module "lambda" {
  source                  = "./modules/lambda"
  account_id              = data.aws_caller_identity.current.account_id
  region                  = var.region
  notification_queue_name = module.sqs.notification_queue_name
  notification_dlq_name   = module.sqs.notification_dlq_name
  dynamodb_table_name     = module.dynamodb.dynamo_table_name
  notifications_sns_topic = module.sns.notification_sns_topic
  sns_sender_email        = var.sns_sender_email
  depends_on              = [module.sqs, module.dynamodb, module.ses, module.sns]
}


