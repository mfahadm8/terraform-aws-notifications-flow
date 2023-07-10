
resource "aws_dynamodb_table" "notification" {
  name         = "notification-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  lifecycle {
    prevent_destroy = false
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "id"
    type = "S"
  }
}

