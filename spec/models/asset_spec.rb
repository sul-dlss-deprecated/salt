require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Asset do
  
  # Relies on the descriptor registered by config/initializers/salt_descriptors.rb
  before(:each) do
     @mock_repo = mock("Stanford::AssetRepository")
     Stanford::AssetRepository.expects(:new).returns(@mock_repo)
     @asset = Asset.new("ff241yc8370", "00001")
  end
  
  
  it "should have all the needed methods" do
    @asset.should respond_to(:get_pdf)
    @asset.should respond_to(:get_thumbnail)
    @asset.should respond_to(:get_page_xml)
    @asset.should respond_to(:get_page_jp2)
  end
  
  
  describe "#get_pdf" do
    it "should get the PDF from the repo" do
      @mock_repo.expects(:get_pdf).with("ff241yc8370") 
      @asset.get_pdf()
    end
  end
  
  describe "#get_thumbnail" do
     it "should get the pdf from the repo" do
       @mock_repo.expects(:get_thumbnail).with("ff241yc8370") 
       @asset.get_thumbnail()
     end
   end
   
   describe "#get_page_xml" do
      it "should get the get_page_xml from the repo" do
        @mock_repo.expects(:get_page_xml).with("ff241yc8370", "00001") 
        @asset.get_page_xml()
      end
    end
  
     describe "#get_page_jp2" do
        it "should get the get_page_jp2 from the repo" do
          @mock_repo.expects(:get_page_jp2).with("ff241yc8370", "00001") 
          @asset.get_page_jp2()
        end
      end
  
  
  describe "#get_json" do
    it "should get the json from the repo" do 
      @mock_repo.expects(:get_json).with("ff241yc8370")
      @asset.get_json
    end
  end
  
  describe "#get_flipbook" do 
    it "should return the flipbook html" do
      Asset.expects(:http).once.returns("<html:flipbook/>")
      @asset.get_flipbook.should == "<html:flipbook/>"
    end
  end
  
  describe "http errors" do
      
    it "should eventually return an error after atempting to follow redirection 10 times" do
      response =  Net::HTTPRedirection.new('1.1', '302', 'Found')
      response['location'] = "http://salt-dev.stanford.edu:8080/flipbook_salt"
      FakeWeb.register_uri(:get, %r|http://salt-dev.stanford.edu:8080/flipbook_salt|, :location => "http://salt-dev.stanford.edu", :response => response, :status => ["301", "Moved Permanently"])
      lambda { @asset.get_flipbook }.should raise_error(ArgumentError)
    end
    
    it "should raise error if there's a problem" do 
      FakeWeb.clean_registry
      response = Net::HTTPError.new("123", "123")
      FakeWeb.register_uri(:get, %r|http://salt-dev.stanford.edu:8080/flipbook_salt|, :body => "Unauthorized", :status => ["401", "Unauthorized"])
      lambda {   @asset.get_flipbook }.should raise_error(Net::HTTPServerException)
    end
    
  end
     
  
  
end