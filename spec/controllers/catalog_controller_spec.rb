require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'devise/test_helpers'



describe CatalogController do
   include Devise::TestHelpers

   
   it "should use CatalogController" do
      controller.should be_an_instance_of(CatalogController)
   end
   
   
   describe "#index" do
     login_user
     
     it "should allow logged in users to index documents" do
       get :index
       response.should_not redirect_to('/')
       response.should be_success
     end
   
     it "should not allow users to index documents" do
        sign_out @user
        get :index
        response.should_not redirect_to('/')
        response.should be_success
     end
     
   end
   
   
    describe "#show" do

       login_user

       it "should allow logged in users to see private documents" do
         get :show, :id=>"druid:bb047vy0535"
         response.should_not redirect_to('/')
         response.should be_success
       end

       it "should not allow users not logged in to see private documents" do
          sign_out @user
          get :show, :id=>"druid:bb047vy0535"
          response.should redirect_to('/')
          response.should_not be_success
       end
       
       it "should  allow users not logged in to see public documents" do
           sign_out @user
           get :show, :id=>"druid:ff241yc8370"
           response.should_not redirect_to('/')
           response.should be_success
        end
       

    end
  
  
end