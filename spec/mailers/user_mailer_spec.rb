require "spec_helper"
require "email_spec"


describe UserMailer do
  
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  
  
  describe ".notification_email" do
    
    before(:all) do
       @email = UserMailer.notification_email("bess@stanford.edu")
  
    end
     
    it "should be set to be delivered to the admin email" do
      expect(@email).to deliver_to("bess@stanford.edu")
    end
     
    it "should have the correct subject" do
      expect(@email).to have_subject("User Request to Saltworks: bess@stanford.edu")
    end
     
     
     
  
    
  end
  
  
  
end
