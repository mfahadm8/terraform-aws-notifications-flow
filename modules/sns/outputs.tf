
output "notification_sns_topic" {
  value = aws_sns_topic.notification_sns.arn
}
