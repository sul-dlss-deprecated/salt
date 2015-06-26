require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'devise/test_helpers'
require 'rubygems'


describe RegistrationsController do 
  include Devise::TestHelpers
  
  
   it "should use RegistrationsController" do
      expect(controller).to be_an_instance_of(RegistrationsController)
   end
  
  it "should send an email when a new user is created" do 
    @request.env["devise.mapping"] = Devise.mappings[:user]
    
    mailer = double("UserMailer")
    expect(mailer).to receive(:deliver).once
    expect(UserMailer).to receive(:notification_email).once.and_return(mailer)
    
    post :create
  end
  
  
  
  
  
end