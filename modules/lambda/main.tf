data "aws_sqs_queue" "notification_queue" {
  name = var.notification_queue_name
}

data "aws_sqs_queue" "notification_dlq_queue" {
  name = var.notification_dlq_name
}

data "aws_dynamodb_table" "notification" {
  name = var.dynamodb_table_name
}

data "archive_file" "notification_forwarder_zip" {
  type        = "zip"
  source_dir  = "${path.root}/src/NotificationsForwarder"
  output_path = "${path.root}/notification_forwarder_package.zip"
}

data "archive_file" "notification_failure_update_zip" {
  type        = "zip"
  source_dir  = "${path.root}/src/NotificationFailureDBUpdateLambda"
  output_path = "${path.root}/tmp/notification_failure_update_package.zip"
}

data "archive_file" "notification_processing_zip" {
  type        = "zip"
  source_dir  = "${path.root}/src/NotificationProcessingLambda"
  output_path = "${path.root}/tmp/notification_processing_package.zip"
}

resource "aws_lambda_function" "notification_forwarder" {
  function_name    = "NotificationForwarder"
  handler          = "index.handler"
  runtime          = "python3.10"
  role             = aws_iam_role.notification_forwarder_role.arn
  source_code_hash = data.archive_file.notification_failure_update_zip.output_base64sha256
  filename         = data.archive_file.notification_failure_update_zip.output_path
  memory_size      = 128
  timeout          = 10

  environment {
    variables = {
      SQS_QUEUE = data.aws_sqs_queue.notification_queue.url
    }
  }

  depends_on = [data.archive_file.notification_failure_update_zip]
}

resource "aws_lambda_function" "notification_failure_update" {
  function_name    = "NotificationFailureDBUpdateLambda"
  handler          = "index.handler"
  runtime          = "python3.10"
  role             = aws_iam_role.notification_failure_update_role.arn
  source_code_hash = data.archive_file.notification_forwarder_zip.output_base64sha256
  filename         = data.archive_file.notification_forwarder_zip.output_path
  memory_size      = 128
  timeout          = 10

  environment {
    variables = {
      DB_TABLE = var.dynamodb_table_name
    }
  }

  depends_on = [data.archive_file.notification_forwarder_zip]

}

resource "aws_lambda_function" "notification_processing" {
  function_name    = "NotificationProcessingLambda"
  handler          = "index.handler"
  runtime          = "python3.10"
  role             = aws_iam_role.notification_processing_role.arn
  source_code_hash = data.archive_file.notification_processing_zip.output_base64sha256
  filename         = data.archive_file.notification_processing_zip.output_path
  memory_size      = 128
  timeout          = 10

  environment {
    variables = {
      DB_TABLE                  = var.dynamodb_table_name
      SNS_TOPIC                 = var.notifications_sns_topic
      SQS_QUEUE                 = data.aws_sqs_queue.notification_queue.url
      DLQ_QUEUE                 = data.aws_sqs_queue.notification_dlq_queue.url
      NOTIFICATION_SES_TEMPLATE = var.notification_ses_template_name
    }
  }

  depends_on = [data.archive_file.notification_processing_zip]

}

resource "aws_iam_policy" "notifications_db_read_policy" {
  name   = "notifications_db_read_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": [
        "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.dynamodb_table_name}",
         "${data.aws_dynamodb_table.notification.stream_arn}"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_policy" "notification_queue_policy" {
  name   = "notification_queue_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:DeleteMessage"
      ],
      "Resource": [
        "arn:aws:sqs:${var.region}:${var.account_id}:${var.notification_queue_name}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "notification_dlq_policy" {
  name   = "notification_dlq_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:DeleteMessage"
      ],
      "Resource": [
        "arn:aws:sqs:${var.region}:${var.account_id}:${var.notification_dlq_name}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logs_policy" {
  name = "lamba-logs-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${var.region}:${var.account_id}:*"
        },

        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.region}:${var.account_id}:log-group:*"
            ]
        }
    ]
}
EOF

}

locals {
  policy_arns = [
    aws_iam_policy.notifications_db_read_policy.arn,
    aws_iam_policy.notification_queue_policy.arn,
    aws_iam_policy.notification_dlq_policy.arn,
    aws_iam_policy.lambda_logs_policy.arn,

  ]
}

resource "aws_iam_role" "notification_forwarder_role" {
  name = "create-order-function-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "notification_forwarder_role_attachment" {
  count      = length(local.policy_arns)
  policy_arn = local.policy_arns[count.index]
  role       = aws_iam_role.notification_forwarder_role.name

}

resource "aws_iam_role" "notification_failure_update_role" {
  name = "get-customer-orders-function-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "notification_failure_update_role_attachment" {
  count      = length(local.policy_arns)
  policy_arn = local.policy_arns[count.index]
  role       = aws_iam_role.notification_failure_update_role.name

}

resource "aws_iam_role" "notification_processing_role" {
  name = "process-order-function-package"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "notification_processing_role_attachment" {
  count      = length(local.policy_arns)
  policy_arn = local.policy_arns[count.index]
  role       = aws_iam_role.notification_processing_role.name

}

# Invoke Permissions
resource "aws_lambda_permission" "dynamodb_stream" {
  statement_id  = "AllowDynamoDB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_forwarder.arn
  principal     = "dynamodb.amazonaws.com"

  source_arn = data.aws_dynamodb_table.notification.arn
}

# Lambda Events
resource "aws_lambda_event_source_mapping" "dynamodb_stream_event" {
  event_source_arn  = data.aws_dynamodb_table.notification.stream_arn
  function_name     = aws_lambda_function.notification_forwarder.arn
  starting_position = "LATEST"
}

resource "aws_lambda_permission" "notification_queue_permission" {
  statement_id  = "AllowLambdaOrderProcessingQueue"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_processing.arn
  principal     = "sqs.amazonaws.com"
  source_arn    = data.aws_sqs_queue.notification_queue.arn
}

resource "aws_lambda_permission" "notification_dlq_permission" {
  statement_id  = "AllowLambdaUpdateStocksQueue"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_failure_update.arn
  principal     = "sqs.amazonaws.com"
  source_arn    = data.aws_sqs_queue.notification_dlq_queue.arn
}


