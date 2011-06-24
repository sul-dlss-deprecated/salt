require 'spec_helper'

describe "ZoteroIngests" do
  describe "GET /zotero_ingests" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get zotero_ingests_path
      response.status.should be(200)
    end
  end
end
