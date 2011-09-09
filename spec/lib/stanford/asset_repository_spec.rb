require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'fakeweb'

describe Stanford::AssetRepository do
  before(:all) do
    # This describe the layout of the assets on the webserver: 
    @druid = "ff12345"
    @page = "000001" 
    #thumbnail
    
    FakeWeb.register_uri(:get,"http://fedoraAdmin:fedoraAdmin@example.com/#{@druid}/thumb.jpg" , :body => "A thumbnail") 
    #pdf
    pdf = "http://fedoraAdmin:fedoraAdmin@example.com/ff12345/ff12345.pdf"
    FakeWeb.register_uri(:get, pdf , :body => "A pdf") 
    #a page jp2000
    FakeWeb.register_uri(:get, "http://fedoraAdmin:fedoraAdmin@example.com/#{@druid}/#{@druid}_#{@page}.jp2", :body => "A jp2000") 
    #a page ALTO XML OCR Text file
    FakeWeb.register_uri(:get, "http://fedoraAdmin:fedoraAdmin@example.com/#{@druid}/#{@druid}_#{@page}.xml", :body => "An alto file") 
    
    
    
  end
  
  
  before(:each) do
    @asset_repo = Stanford::AssetRepository.new("http://example.com", "fedoraAdmin", "fedoraAdmin")
  end
  
  it "should get the thumbnail for an asset but return nil for one that doesn't exist" do
     
     @asset_repo.get_thumbnail(@druid).should == "A thumbnail"
     @asset_repo.get_thumbnail("bs").should be_nil
  end
  
  it "should get the pdf for an asset" do 
    @asset_repo.get_pdf(@druid).should == "A pdf"
    @asset_repo.get_pdf("bs").should be_nil
  end
  
  it "should get the jp2000 for a page of an asset" do
    @asset_repo.get_page_jp2(@druid, @page).should == "A jp2000"
    @asset_repo.get_page_jp2("bs", "more bs").should be_nil
    
  end
  
  it "should get the alto for a page of an asset" do
    @asset_repo.get_page_xml(@druid, @page).should == "An alto file"
    @asset_repo.get_page_xml("bs", "more bs").should be_nil
  end
  
end