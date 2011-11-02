require "spec_helper"
require "email_spec"


describe UserMailer do
  
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  
  
  describe ".notification_email" do
    
    before(:all) do
       @email = UserMailer.notification_email("jojo@yahoo.com")
  
    end
     
    it "should be set to be delivered to the admin email" do
      @email.should deliver_to("cfitz@stanford.edu")
    end
     
    it "should have the correct subject" do
      @email.should have_subject("User Request to Saltworks: jojo@yahoo.com")
    end
     
     
     
  
    
  end
  
  
  
end
