require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'devise/test_helpers'
require 'rubygems'


describe RegistrationsController do 
  include Devise::TestHelpers
  
  
   it "should use RegistrationsController" do
      controller.should be_an_instance_of(RegistrationsController)
   end
  
  it "should send an email when a new user is created" do 
    @request.env["devise.mapping"] = Devise.mappings[:user]
    
    mailer = mock("UserMailer")
    mailer.should_receive(:deliver).once
    UserMailer.should_receive(:notification_email).once.and_return(mailer)
    
    post :create
  end
  
  
  
  
  
end