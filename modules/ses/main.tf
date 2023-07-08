resource "aws_ses_template" "notification_ses_template" {
  name    = "NotificationSESTemplate"
  subject = "Greetings, {{name}}!"
  html    = "<h1>Hello {{name}},</h1><p>{{favoriteanimal}}.</p>"
  text    = "Hello {{name}},\r\n{{favoriteanimal}}."
}
