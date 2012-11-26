require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'fakeweb'

describe Stanford::AssetRepository do
  before(:all) do
    # This describe the layout of the assets on the webserver:
    @druid = "ff12345"
    @page = "000001"
    #thumbnail

  end


  before(:each) do
    @asset_repo = Stanford::AssetRepository.new("http://fedoraAdmin:fedoraAdmin@example.com/assets")
  end

  it "should get the thumbnail for an asset but return nil for one that doesn't exist" do
    RestClient.expects(:get).with("http://fedoraAdmin:fedoraAdmin@example.com/assets/#{@druid}/thumb.jpg").returns(mock(:body => '123'))
    @asset_repo.get_thumbnail(@druid).should == '123'
  end

  it "should get the pdf for an asset" do
    RestClient.expects(:get).with("http://fedoraAdmin:fedoraAdmin@example.com/assets/#{@druid}/#{@druid}.pdf").returns(mock(:body => '123'))
    @asset_repo.get_pdf(@druid).should == '123'
  end

  it "should get the jp2000 for a page of an asset" do
    RestClient.expects(:get).with("http://fedoraAdmin:fedoraAdmin@example.com/assets/#{@druid}/#{@druid}_#{@page}.jp2").returns(mock(:body => '123'))

    @asset_repo.get_page_jp2(@druid, @page).should == '123'
  end

  it "should get the alto for a page of an asset" do
    RestClient.expects(:get).with("http://fedoraAdmin:fedoraAdmin@example.com/assets/#{@druid}/#{@druid}_#{@page}.xml").returns(mock(:body => '123'))

    @asset_repo.get_page_xml(@druid, @page).should == '123'
  end

end