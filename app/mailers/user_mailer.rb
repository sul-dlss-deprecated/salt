class UserMailer < ActionMailer::Base
  default :from => "no-reply@salt-app-dev.stanford.edu"

  def notication_email(user_email)
    mail(:to => "cfitz@stanford.edu", :subject => "User Request to Saltworks: #{user_email}")
  end

end
