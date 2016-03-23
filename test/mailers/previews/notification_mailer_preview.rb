# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/otp_notification
  def otp_notification
    NotificationMailer.otp_notification(User.first)
  end

end
