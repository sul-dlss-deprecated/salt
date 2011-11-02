# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  
  def create
    super && notification_email
  end

protected


def notification_email
  UserMailer.notification_email(resource.email).deliver
end


end