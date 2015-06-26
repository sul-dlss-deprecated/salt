require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'devise/test_helpers'


# to do. need to add fixture data to test approved/not approved q's. 


describe UsersController do
   include Devise::TestHelpers

   
   it "should use UsersController" do
      expect(controller).to be_an_instance_of(UsersController)
   end
   
  describe "#index non-admin" do #we have to put these in different describes to get factory girl to work
    login_user
    
    it "should not allow non-admin users to see the page" do
      get :index
      expect(response).to redirect_to('/')
      expect(response).not_to be_success
    end
  end
 
  describe "#index admin" do
    login_admin
    it "should not allow non-admin users to see the page" do
      get :index
      expect(response).not_to redirect_to('/')
      expect(response).to be_success
    end
    
    it "should show users awaiting approval" do
      expect(User).to receive(:find_all_by_approved).with(false)
      get :index, {:approved => "false"}
      expect(response).not_to redirect_to('/')
      expect(response).to be_success
      
    end
    
  end
  
   describe "#edit admin" do
    login_admin
    it "should get the user by id for updating" do
      expect(User).to receive(:find_by_id).with("1")
      get :edit, :id=>1 
      expect(response).not_to redirect_to('/')
      expect(response).to be_success
    end
   end
  
    describe "#edit non-admin" do
     it "should get the user by id for updating" do
       get :edit, :id=>1
       expect(response).to redirect_to('/')
       expect(response).not_to be_success
     end
    end
  
  describe "#show non-admin" do
    login_user
    
    it "should not allow non-admin users to see the page" do
      get :show, :id=> 1
      expect(response).to redirect_to('/')
      expect(response).not_to be_success
    end  
  end
  
  describe "#show admin" do
     login_admin
     it "should not allow non-admin users to see the page" do
       get :show, :id => 1
       expect(response).not_to redirect_to('/')
       expect(response).to be_success
     end
   end
   
   
   describe "#update admin" do
     login_admin
     it "should update the user when given the proper infomation" do
        user = create(:not_approved)
        expect(User).to receive(:find).with("666").and_return(user)
        get :update, :id => 666, :approved => true, :email => "foobar@foofoo.com"
        expect(response).to redirect_to("/")
        expect(flash[:notice]).to eq("Successfully updated User.")
     end
     
     it "should not update the user when given crap" do
       user = create(:not_approved)
       expect(User).to receive(:find).with("666").and_return(user)
       expect(user).to receive(:update_attributes).and_return(false)
       get :update, :id => 666, :approved => true, :email => "this is not an email."
       expect(response).not_to redirect_to("/")
       expect(response).to render_template("users/edit")
       expect(flash[:notice]).to be_nil
     end
   end
   
   describe "#update non admin" do
     
     it "should redirect to root when not admin" do
       get :update, :id => 666, :approved => true, :email => "foobar@foofoo.com"
       expect(response).to redirect_to("/")
       expect(flash[:notice]).to eq("You currently do not have permissions to view this section. If this is an error, please contact the system administrator.")
     end
   end
   
   #this is inherited from the applications controller
   describe "stanford web-auth" do 
     
     it "should log in a user if they've webauthed and have an account made" do
       user = create(:admin)
       request.env["WEBAUTH_USER"] = "mrbossman"
       expect(User).to receive(:find_by_username).with("mrbossman").and_return(user)
       get :show, :id => 1
       expect(response).to be_success 
     end
     
     it "should not allow the user to do anything if there is no user in the database" do
       request.env["WEBAUTH_USER"] = "mrbossman"
       expect(User).to receive(:find_by_username).with("mrbossman").and_return(nil)
       get :show, :id => 1
       expect(response).not_to be_success 
       expect(response).to redirect_to('/users/sign_up')
       expect(flash[:notice]).to eq("Hello mrbossman. You must first request a user account to access the content.") 
     end
     
   end
  




end
