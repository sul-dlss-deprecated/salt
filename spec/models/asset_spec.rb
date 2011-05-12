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
  
  
  
  
  
end