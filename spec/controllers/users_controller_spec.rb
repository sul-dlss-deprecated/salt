require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'devise/test_helpers'


# to do. need to add fixture data to test approved/not approved q's. 


describe UsersController do
   include Devise::TestHelpers

   
   it "should use UsersController" do
      controller.should be_an_instance_of(UsersController)
   end
   
  describe "#index non-admin" do #we have to put these in different describes to get factory girl to work
    login_user
    
    it "should not allow non-admin users to see the page" do
      get :index
      response.should redirect_to('/')
      response.should_not be_success
    end
  end
 
  describe "#index admin" do
    login_admin
    it "should not allow non-admin users to see the page" do
      get :index
      response.should_not redirect_to('/')
      response.should be_success
    end
  end
  
  describe "#show non-admin" do
    login_user
    
    it "should not allow non-admin users to see the page" do
      get :show, :id=> 1
      response.should redirect_to('/')
      response.should_not be_success
    end  
  end
  
  describe "#show admin" do
     login_admin
     it "should not allow non-admin users to see the page" do
       get :show, :id => 1
       response.should_not redirect_to('/')
       response.should be_success
     end
   end
  




end