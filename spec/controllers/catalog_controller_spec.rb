require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'devise/test_helpers'



describe CatalogController do
   include Devise::TestHelpers

   
   it "should use CatalogController" do
      expect(controller).to be_an_instance_of(CatalogController)
   end
   
   
   describe "#index" do
     login_user
     
     it "should allow logged in users to index documents" do
       get :index
       expect(response).not_to redirect_to('/')
       expect(response).to be_success
     end
     
    it "should allow logged in users to index documents" do
      get :index, { :search_field => "fulltext"}
      expect(response).not_to redirect_to('/')
      expect(response).to be_success
    end
    
   
     it "should  allow users to index documents" do
        sign_out @user
        get :index
        expect(response).not_to redirect_to('/')
        expect(response).to be_success
     end
     
     it "should allow logged in users to index documents" do
        sign_out @user
        get :index, { :search_field => "fulltext"}
        expect(response).not_to redirect_to('/')
        expect(response).to be_success
      end
     
   end
   
   
    describe "#show logged-in" do

       login_user

       it "should allow logged in users to see private documents" do
         get :show, :id=>"druid:bb047vy0535"
         expect(response).not_to redirect_to('/')
         expect(response).to be_success
       end
     end    
   

    describe "#show not logged-in" do
       it "should not allow users not logged in to see private documents" do
          get :show, :id=>"druid:bb047vy0535"
          expect(response).to redirect_to('/')
          expect(response).not_to be_success
       end
       
       it "should  allow users not logged in to see public documents" do
           get :show, :id=>"druid:pt839dg9461"
           expect(response).not_to redirect_to('/')
           expect(response).to be_success
        end
    end
    
    
    
    
  
  
end