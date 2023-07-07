
output "notification_queue_name" {
  value = aws_sqs_queue.notification_queue.name
}

output "notification_dlq_name" {
  value = aws_sqs_queue.notification_dlq.name
}
