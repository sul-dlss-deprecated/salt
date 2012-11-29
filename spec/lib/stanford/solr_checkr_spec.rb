require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'equivalent-xml'

describe Stanford::SolrCheckr do
  
  
  describe "#initalize" do
    
    it "should initalize properly" do
      zi = ZoteroIngest.new
      zi.save
      
      zcheck = Stanford::SolrCheckr.new(fixture('zotero_ds.xml').path, zi)
      zcheck.should be_an_instance_of(Stanford::SolrCheckr)
      
    end
    
    it "should log an error if a file is not given" do
      lambda { Stanford::SolrCheckr.new("notafile") }.should raise_error(ArgumentError)
    end
    
  end
  
  
  describe "#check_documents" do
    
    before(:each) do
      @zi = ZoteroIngest.new
      @zi.save
      ZoteroIngest.expects(:update).at_least(1)
      @zcheck = Stanford::SolrCheckr.new(fixture('zotero_ds.xml').path, @zi)
      
    end
    
    it "should check the document given to it" do
      @zcheck.expects(:check_document).once
      @zcheck.check_documents  
    end
  
     it "should check the document given to it" do
        @zcheck.check_documents  
    end


  end
  
  
  
  
  
  
  
  
end