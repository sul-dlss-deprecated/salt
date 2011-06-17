require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'devise/test_helpers'
require 'rubygems'


describe AssetController do
   include Devise::TestHelpers

   
   it "should use AssetController" do
      controller.should be_an_instance_of(AssetController)
   end
   
   
   describe "#show private logged in" do
 
      login_user
    
      it "should allow logged in users to see private documents" do
        get :show, :id=>"bb047vy0535"
        response.should_not redirect_to('/')
        response.should be_success
      end
   end
    
    
    # have to put this in another describe block to clear ot the session. 
    describe "#show private not allowed" do 
      it "should not allow users not logged in to see private documents" do     
         get :show, :id=>"bb047vy0535"
         response.should redirect_to('/')
         response.should_not be_success
      end
      
      it "should allow users not logged in to see public documents" do 
         get :show, :id=>"pt839dg9461"
         response.should_not redirect_to('/')
         response.should be_success
      end
    
    
   end 
  
  describe "#show_page logged_in private" do
    
    login_user
    
    it "should allow logged in users to see private pages" do
        sign_in @user
        get :show_page, :id=>"bb047vy0535", :page => "00001"
        response.should_not redirect_to('/')
        response.should be_success
    end
  end
 
  describe "#show_page not logged_in private" do
 
    it "should not allow users not logged in to see private documents" do
       get :show_page, :id=>"bb047vy0535", :page => "00001"
       response.should redirect_to('/')
       response.should_not be_success
    end
    
    it "should allow users not logged in to see public documents" do 
         get :show_page, :id=>"pt839dg9461", :page => "00001"
         response.should_not redirect_to('/')
         response.should be_success
    end
     
  end
  
  describe "#get_flipbook_asset" do
    
    #http://salt-app-dev.stanford.edu/assets/js/GnuBook/GnuBook.js   
    it "should pass through requests for javascript for the embedded flipbook " do
          get :get_flipbook_asset, :file=> "GnuBook/GnuBook.js"
          response.should_not redirect_to('/')
          response.should be_success
    end
  
    #http://salt-app-dev.stanford.edu/assets/css/GnuBookEmbed.css
    it "should pass through requests for css for the embedded flipbook " do
          get :get_flipbook_asset, :file=> "GnuBookEmbed.css", :format => :css
          response.should_not redirect_to('/')
          response.should be_success
    end
      
    #http://salt-app-dev.stanford.edu/assets/images/toolbar_bg.png  
    it "should pass through requests for css for the embedded flipbook " do
          get :get_flipbook_asset, :file=> "toolbar_bg.png", :format => :png
          response.should_not redirect_to('/')
          response.should be_success
    end  
     
  end
  
  
end