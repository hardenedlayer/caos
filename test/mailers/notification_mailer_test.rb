require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  test "otp_notification" do
    mail = NotificationMailer.otp_notification
    assert_equal "Otp notification", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
