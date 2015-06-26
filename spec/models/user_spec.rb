require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  
 
  
  describe "#inactive_message" do
    
    it "should give indicate if the user is not approved" do
       user = create(:not_approved)
       expect(user.inactive_message).to eq(:not_approved)
    end
    
    it "should give give the inactive message if the user is approved" do 
      user = create(:admin)
      expect(user.inactive_message).to eq(:inactive)
    end
    
  end
    
  
end