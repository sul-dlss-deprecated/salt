class ZoteroIngestsController < ApplicationController
  # GET /zotero_ingests
  # GET /zotero_ingests.xml
  def index
    @zotero_ingests = ZoteroIngest.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @zotero_ingests }
    end
  end

  # GET /zotero_ingests/1
  # GET /zotero_ingests/1.xml
  def show
    @zotero_ingest = ZoteroIngest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @zotero_ingest }
    end
  end

 

 
end
