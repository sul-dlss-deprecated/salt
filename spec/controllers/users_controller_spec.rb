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
    
    it "should show users awaiting approval" do
      User.expects(:find_all_by_approved).with(false)
      get :index, {:approved => "false"}
      response.should_not redirect_to('/')
      response.should be_success
      
    end
    
  end
  
   describe "#edit admin" do
    login_admin
    it "should get the user by id for updating" do
      User.expects(:find_by_id).with(1)
      get :edit, :id=>1 
      response.should_not redirect_to('/')
      response.should be_success
    end
   end
  
    describe "#edit non-admin" do
     it "should get the user by id for updating" do
       get :edit, :id=>1
       response.should redirect_to('/')
       response.should_not be_success
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
   
   
   describe "#update admin" do
     login_admin
     it "should update the user when given the proper infomation" do
        user = Factory.create(:not_approved)
        User.expects(:find).with(666).returns(user)
        get :update, :id => 666, :approved => true, :email => "foobar@foofoo.com"
        response.should redirect_to("/")
        flash[:notice].should == "Successfully updated User."
     end
     
     it "should not update the user when given crap" do
       user = Factory.create(:not_approved)
       User.expects(:find).with(666).returns(user)
       user.expects(:update_attributes).returns(false)
       get :update, :id => 666, :approved => true, :email => "this is not an email."
       response.should_not redirect_to("/")
       response.should render_template("users/edit")
       flash[:notice].should be_nil
     end
   end
   
   describe "#update non admin" do
     
     it "should redirect to root when not admin" do
       get :update, :id => 666, :approved => true, :email => "foobar@foofoo.com"
       response.should redirect_to("/")
       flash[:notice].should == "You currently do not have permissions to view this section. If this is an error, please contact the system administrator."
     end
   end
   
   #this is inherited from the applications controller
   describe "stanford web-auth" do 
     
     it "should log in a user if they've webauthed and have an account made" do
       user = Factory.create(:admin)
       request.env["WEBAUTH_USER"] = "mrbossman"
       User.expects(:find_by_username).with("mrbossman").returns(user)
       get :show, :id => 1
       response.should be_success 
     end
     
     it "should not allow the user to do anything if there is no user in the database" do
       request.env["WEBAUTH_USER"] = "mrbossman"
       User.expects(:find_by_username).with("mrbossman").returns(nil)
       get :show, :id => 1
       response.should_not be_success 
       response.should redirect_to('/users/sign_up')
       flash[:notice].should ==  "Hello mrbossman. You must first request a user account to access the content." 
     end
     
   end
  




end