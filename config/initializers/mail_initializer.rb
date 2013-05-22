ActionMailer::Base.smtp_settings = { 
  user_name: ENV["smtp_username"],
  password: ENV["smtp_password"],
  address: 'smtp.gmail.com',
  port: 587,
  authentication: :plain,
  enable_starttls_auto: true,
}
