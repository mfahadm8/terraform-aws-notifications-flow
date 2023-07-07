output "dynamodb_table_name" {
  value = module.dynamodb.aws_dynamodb_table.notification.name
}

output "sqs_queue_url" {
  value = module.sqs.aws_sqs_queue.notification_queue.url
}

output "sqs_dlq_url" {
  value = module.sqs.aws_sqs_queue.notification_dlq.url
}

output "sns_topic_arn" {
  value = module.sns.aws_sns_topic.notification_sns.arn
}
