class UserMailer < ActionMailer::Base
  default :from => "no-reply@salt-app-dev.stanford.edu"
      
  def notification_email(user_email)
    mail(:to => "bess@stanford.edu", :subject => "User Request to Saltworks: #{user_email}")
  end

end
