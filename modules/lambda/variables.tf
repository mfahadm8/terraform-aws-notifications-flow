variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS Account Id"
  type        = string
}

variable "notification_queue_name" {
  description = "Notification Queue Name"
  type        = string
}

variable "notification_dlq_name" {
  description = "Notification DLQ Name"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Notifications DynamoDB Table Name"
  type        = string
}

variable "notifications_sns_topic" {
  description = "Notifications DynamoDB Table Name"
  type        = string
}

variable "notification_ses_template_name" {
  description = "Notifications SES Template Name"
  type        = string
}

variable "sns_sender_email" {
  description = "SES Source Email Address"
  type        = string
}
