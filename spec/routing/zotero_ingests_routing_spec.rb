require "spec_helper"

describe ZoteroIngestsController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/zotero_ingests")).to route_to("zotero_ingests#index")
    end

    it "routes to #new" do
      expect(get("/zotero_ingests/new")).to route_to("zotero_ingests#new")
    end

    it "routes to #show" do
      expect(get("/zotero_ingests/1")).to route_to("zotero_ingests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/zotero_ingests/1/edit")).to route_to("zotero_ingests#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/zotero_ingests")).to route_to("zotero_ingests#create")
    end

    it "routes to #update" do
      expect(put("/zotero_ingests/1")).to route_to("zotero_ingests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/zotero_ingests/1")).to route_to("zotero_ingests#destroy", :id => "1")
    end

  end
end
