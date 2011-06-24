require "spec_helper"

describe ZoteroIngestsController do
  describe "routing" do

    it "routes to #index" do
      get("/zotero_ingests").should route_to("zotero_ingests#index")
    end

    it "routes to #new" do
      get("/zotero_ingests/new").should route_to("zotero_ingests#new")
    end

    it "routes to #show" do
      get("/zotero_ingests/1").should route_to("zotero_ingests#show", :id => "1")
    end

    it "routes to #edit" do
      get("/zotero_ingests/1/edit").should route_to("zotero_ingests#edit", :id => "1")
    end

    it "routes to #create" do
      post("/zotero_ingests").should route_to("zotero_ingests#create")
    end

    it "routes to #update" do
      put("/zotero_ingests/1").should route_to("zotero_ingests#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/zotero_ingests/1").should route_to("zotero_ingests#destroy", :id => "1")
    end

  end
end
