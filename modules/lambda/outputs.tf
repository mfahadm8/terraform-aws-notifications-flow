
output "notification_forwarder_lambda_name" {
  value = aws_lambda_function.notification_forwarder.function_name
}

output "notification_failure_update_lambda_name" {
  value = aws_lambda_function.notification_failure_update.function_name
}

output "notification_processing_lambda_name" {
  value = aws_lambda_function.notification_processing.function_name
}
