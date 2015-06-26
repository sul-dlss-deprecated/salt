require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'devise/test_helpers'
require 'rubygems'


describe AssetController do
   include Devise::TestHelpers

   
   it "should use AssetController" do
      expect(controller).to be_an_instance_of(AssetController)
   end
   
   
   describe "#show private logged in" do
 
      login_user
    
      it "should allow logged in users to see private documents" do
        get :show, :id=>"bb047vy0535"
        expect(response).not_to redirect_to('/')
        expect(response).to be_success
      end
      
      # id's with 'druid:' prefix should redirect properly
      it "should redirect if id has a druid: prefix" do
        get :show, :id=> 'druid:bb047vy0535'
        expect(response).to redirect_to(:action=> 'show', :id => 'bb047vy0535')
      end
      
   end
    
    
    # have to put this in another describe block to clear ot the session. 
    describe "#show private not allowed" do 
      it "should not allow users not logged in to see private documents" do     
         get :show, :id=>"bb047vy0535"
         expect(response).to redirect_to('/')
         expect(response).not_to be_success
      end
      
        # id's with 'druid:' prefix should redirect when not logged in just like when logged in.
        it "should redirect if id has a druid: prefix" do
          get :show, :id=> 'druid:bb047vy0535'
          expect(response).to redirect_to(:action=> 'show', :id => 'bb047vy0535')
        end
      
      
      it "should allow users not logged in to see public documents" do 
         get :show, :id=>"pt839dg9461"
         expect(response).not_to redirect_to('/')
         expect(response).to be_success
      end
      
      # id's with 'druid:' prefix should redirect just like one without the prefix
      it "should redirect if id has a druid: prefix" do
          get :show, :id=> 'druid:pt839dg9461'
          expect(response).to redirect_to(:action=> 'show', :id => 'pt839dg9461')
      end
    
    
   end 
  
  describe "#show_page logged_in private" do
    
    login_user
    
    it "should allow logged in users to see private pages" do
        sign_in @user
        get :show_page, :id=>"bb047vy0535", :page => "00001"
        expect(response).not_to redirect_to('/')
        expect(response).to be_success
    end
  end
 
  describe "#show_page not logged_in private" do
 
    it "should not allow users not logged in to see private documents" do
       get :show_page, :id=>"bb047vy0535", :page => "00001"
       expect(response).to redirect_to('/')
       expect(response).not_to be_success
    end
    
    it "should allow users not logged in to see public documents" do 
         get :show_page, :id=>"pt839dg9461", :page => "00001"
         expect(response).not_to redirect_to('/')
         expect(response).to be_success
    end
     
  end
  
  describe "#get_flipbook_asset" do
    
    #http://salt-app-dev.stanford.edu/assets/js/GnuBook/GnuBook.js   
    it "should pass through requests for javascript for the embedded flipbook " do
          get :get_flipbook_asset, :file=> "GnuBook/GnuBook.js"
          expect(response).not_to redirect_to('/')
          expect(response).to be_success
    end
  
    #http://salt-app-dev.stanford.edu/assets/css/GnuBookEmbed.css
    it "should pass through requests for css for the embedded flipbook " do
          get :get_flipbook_asset, :file=> "GnuBookEmbed.css", :format => :css
          expect(response).not_to redirect_to('/')
          expect(response).to be_success
    end
      
    #http://salt-app-dev.stanford.edu/assets/images/toolbar_bg.png  
    it "should pass through requests for css for the embedded flipbook " do
          get :get_flipbook_asset, :file=> "toolbar_bg.png", :format => :png
          expect(response).not_to redirect_to('/')
          expect(response).to be_success
    end  
     
  end
  
  
end