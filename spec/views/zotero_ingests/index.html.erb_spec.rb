require 'spec_helper'

describe "zotero_ingests/index.html.erb" do
  before(:each) do
    assign(:zotero_ingests, [ Factory.create(:zotero_ingest), Factory.create(:zotero_ingest)])
    
     
  end

  it "renders a list of zotero_ingests" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Filename".to_s, :count => 2
  end
end
