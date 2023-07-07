
resource "aws_dynamodb_table" "notification" {
  name         = "notification-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  lifecycle {
    prevent_destroy = true
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "id"
    type = "N"
  }

  attribute {
    name = "notification_type"
    type = "S"
  }
  attribute {
    name = "notification_scenario"
    type = "S"
  }
  attribute {
    name = "mobile_no"
    type = "S"
  }
  attribute {
    name = "sms_message"
    type = "S"
  }
  attribute {
    name = "to_email_address"
    type = "S"
  }
  attribute {
    name = "to_name"
    type = "S"
  }
  attribute {
    name = "profile_id"
    type = "S"
  }
  attribute {
    name = "job_id"
    type = "S"
  }
  attribute {
    name = "job_title"
    type = "S"
  }
  attribute {
    name = "email_template"
    type = "S"
  }
  attribute {
    name = "read_date_time"
    type = "N"
  }
}

