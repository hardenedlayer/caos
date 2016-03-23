class NotificationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.otp_notification.subject
  #
  def otp_notification user
    @user = user
    mail to: @user.mail
  end
end
