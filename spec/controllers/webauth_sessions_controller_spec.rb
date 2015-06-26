require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'devise/test_helpers'


describe WebauthSessionsController do
  
   it "should use WebauthSessionsController" do
      expect(controller).to be_an_instance_of(WebauthSessionsController)
   end
   
   describe "#new" do
    
     it "should redirect to root if none of the sessions or params are set" do
        session[:bounce]  = nil
       get :new
       expect(response).to redirect_to("/")
       
     end
     
     it "should redirect if sessions[:bounce] is set" do
        session[:bounce] = "http://google.com"
        get :new
        expect(response).to be_redirect     
     end
     
     it "should redirect if params[:bounce] is set" do
        session[:bounce]  = nil
       get :new, {:bounce => "http://google.com"}
       expect(response).to be_redirect  
     end
    
   end
  
end



