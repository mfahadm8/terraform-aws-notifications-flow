resource "aws_ses_template" "notification_ses_template" {
  name    = "NotificationSESTemplate"
  subject = "Greetings, {{name}}!"
  html    = "<h1>Hello {{name}},</h1><p>{{favoriteanimal}}.</p>"
  text    = "Hello {{name}},\r\n{{favoriteanimal}}."
}
resource "aws_ses_template" "notification_ses_template" {
  name    = "NotificationUserPasswordChangeRequest"
  subject = "Greetings, {{name}}!"
  html    = "<h1>Hello {{name}},</h1><p>Use this verification code to reset password</p><h2>Code:{{verification_code}}</h2>"
  text    = "Hello {{name}},\r\nUse this verification code to reset password.\nCode:{{verification_code}}."
}

resource "aws_ses_template" "notification_ses_template" {
  name    = "NotificationNewUserSignup"
  subject = "Greetings, {{name}}!"
  html    = "<h1>Hello {{name}},</h1><h2>Thank you for your registration</h2>"
  text    = "Hello {{name}},\r\nThank you for your registration."
}
