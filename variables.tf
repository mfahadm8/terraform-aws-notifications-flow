variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "sns_sender_email" {
  description = "SES Source Email Address"
  type        = string
  default     = "Fahad <mfahadm8@gmail.com>"
}
