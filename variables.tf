variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "sns_sender_email" {
  description = "SES Source Email Address"
  type        = string
  default     = "mfahadm8@gmail.com"
}
