SMTP_SETTINGS = {
  user_name: ENV["SMTP_USERNAME"],
  password: ENV["SMTP_PASSWORD"],
  domain: ENV["SMTP_DOMAIN"],
  address: ENV["SMTP_ADDRESS"],
  port: 465,
  authentication: :plain,
  enable_starttls_auto: true
}
