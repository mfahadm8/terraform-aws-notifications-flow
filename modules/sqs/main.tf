resource "aws_sqs_queue" "notification_queue" {
  name = "notification_queue"
}

resource "aws_sqs_queue" "notification_dlq" {
  name = "notification_dlq"
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.notification_queue.arn]
  })
}

resource "aws_sqs_queue_redrive_policy" "notification_queue" {
  queue_url = aws_sqs_queue.notification_queue.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notification_dlq.arn
    maxReceiveCount     = 3
  })
}
