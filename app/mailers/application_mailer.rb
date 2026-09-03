class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Recipy <noreply@example.com>")
  layout "mailer"
end
