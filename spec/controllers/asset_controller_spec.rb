require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'devise/test_helpers'
require 'rubygems'


describe AssetController do
   include Devise::TestHelpers

   
   it "should use AssetController" do
      controller.should be_an_instance_of(AssetController)
   end
   
   
   describe "#show" do
 
      login_user
    
      it "should allow logged in users to see private documents" do
        get :show, :id=>"bb047vy0535"
        response.should_not redirect_to('/')
        response.should be_success
      end
    
      it "should not allow users not logged in to see private documents" do
         sign_out @user
         get :show, :id=>"bb047vy0535"
         response.should redirect_to('/')
         response.should_not be_success
      end
      
      it "should allow users not logged in to see public documents" do 
        sign_out @user
         get :show, :id=>"ff241yc8370"
         response.should_not redirect_to('/')
         response.should be_success
        
      end
    
    
   end 
  
  describe "#show_page" do
    
    login_user
    
    it "should allow logged in users to see private pages" do
        sign_in @user
        get :show_page, :id=>"bb047vy0535", :page => "00001"
        response.should_not redirect_to('/')
        response.should be_success
    end
    
   it "should not allow users not logged in to see private documents" do
       sign_out @user
       get :show_page, :id=>"bb047vy0535", :page => "00001"
       response.should redirect_to('/')
       response.should_not be_success
    end
    
     it "should allow users not logged in to see public documents" do 
        sign_out @user
         get :show, :id=>"ff241yc8370", :page => "00001"
         response.should_not redirect_to('/')
         response.should be_success
        
      end
     
  end
  
  
end