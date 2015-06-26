require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Asset do
  
  # Relies on the descriptor registered by config/initializers/salt_descriptors.rb
  before(:each) do
     @mock_repo = double("Stanford::AssetRepository")
     expect(Stanford::AssetRepository).to receive(:new).and_return(@mock_repo)
     @asset = Asset.new("ff241yc8370", "00001")
  end
  
  
  it "should have all the needed methods" do
    expect(@asset).to respond_to(:get_pdf)
    expect(@asset).to respond_to(:get_thumbnail)
    expect(@asset).to respond_to(:get_page_xml)
    expect(@asset).to respond_to(:get_page_jp2)
  end
  
  
  describe "#get_pdf" do
    it "should get the PDF from the repo" do
      expect(@mock_repo).to receive(:get_pdf).with("ff241yc8370") 
      @asset.get_pdf()
    end
  end
  
  describe "#get_thumbnail" do
     it "should get the pdf from the repo" do
       expect(@mock_repo).to receive(:get_thumbnail).with("ff241yc8370") 
       @asset.get_thumbnail()
     end
   end
   
   describe "#get_page_xml" do
      it "should get the get_page_xml from the repo" do
        expect(@mock_repo).to receive(:get_page_xml).with("ff241yc8370", "00001") 
        @asset.get_page_xml()
      end
    end
  
     describe "#get_page_jp2" do
        it "should get the get_page_jp2 from the repo" do
          expect(@mock_repo).to receive(:get_page_jp2).with("ff241yc8370", "00001") 
          @asset.get_page_jp2()
        end
      end
  
  
  describe "#get_json" do
    it "should get the json from the repo" do 
      expect(@mock_repo).to receive(:get_json).with("ff241yc8370")
      @asset.get_json
    end
  end
  
  describe "#get_flipbook" do 
    it "should return the flipbook html" do
      expect(RestClient).to receive(:get).with("#{Settings.flipbook.url}/embed.jsp?id=druid:#{@asset.druid}").and_return(double(:body => "<html:flipbook/>"))

      expect(@asset.get_flipbook).to eq("<html:flipbook/>")
    end
  end
  
  
  
end
