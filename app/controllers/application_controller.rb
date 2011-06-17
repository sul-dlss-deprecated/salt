
class ApplicationController < ActionController::Base
   layout "salt"
  
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 
  
  protect_from_forgery
   before_filter [:set_current_user]
  
 


protected 
  
  def store_bounce 
     session[:bounce]=params[:bounce]
  end
  
  def set_current_user
    if current_user.nil? or request.env['WEBAUTH_USER'].blank?
        user = User.find_by_username(request.env['WEBAUTH_USER'])
        !user.nil? ? sign_in(user) : nil 
    end
  end
  
  def choose_layout
    'application' unless request.xml_http_request? || ! params[:no_layout].blank?
  end

  
  
end
