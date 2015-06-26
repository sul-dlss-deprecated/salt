
class ApplicationController < ActionController::Base
  include Squash::Ruby::ControllerMethods
  enable_squash_client

   layout "salt"
  
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
   include BlacklightHelper
   
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 
  
  protect_from_forgery
  before_filter :set_current_user, :store_bounce
   


protected 
  
  
  # => store_bounce: used to capture bounce paramaters from Stanford WebAuth
  #
  def store_bounce
     session[:bounce]=params[:bounce]
  end
  
  # =>  set_current_user: checks the WEBAUTH_USER param to see if a Stanford WebAuth user is set. If there is, the user is logged in. 
  #
  def set_current_user
    if current_user.nil? and !request.env['WEBAUTH_USER'].blank?
        user = User.find_by_username(request.env['WEBAUTH_USER'])
        !user.nil? ? sign_in(user) :  redirect_to("/users/sign_up", :notice => "Hello #{request.env['WEBAUTH_USER']}. You must first request a user account to access the content.") 
    end
  end
  
  def choose_layout
    'application' unless request.xml_http_request? || ! params[:no_layout].blank?
  end

  
  
end
