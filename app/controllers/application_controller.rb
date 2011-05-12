
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 
  include(Rack::Webauth::Helpers)
  
  delegate :logged_in?, :to => :webauth
 



  protect_from_forgery
end
