require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include BlacklightHelper


describe BlacklightHelper do
  
 describe "#application_name" do 
   it "should return the name of the application" do
     helper.application_name.should ==  "SALT (Self Archiving Legacy Toolkit)" 
   end
 end
  
 describe "#link_to_document" do
   it "should consist of the document title wrapped in a <a>" do
         data = {'id'=>'druid:foo','title_display'=>['bar'] }
         @document = SolrDocument.new(data)
         helper.link_to_document(@document, { :label => :title_display }).should have_selector("a", :content => 'bar', :count => 1)
   end
   
    it "should add druid: prefix even if the id does not have it" do
          data = {'id'=>'foo','title_display'=>['bar'] }
          @document = SolrDocument.new(data)
          helper.link_to_document(@document, { :label => :title_display }).should have_selector("a[href='/catalog/druid:foo']")
    end
   

 end

  

  
end
