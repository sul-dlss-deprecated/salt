class ZoteroIngestsController < ApplicationController
  
  before_filter :enforce_permissions, :only => [:show, :index]
  
  
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

  protected

   def enforce_permissions
     unless current_user && current_user.admin?
       redirect_to("/", :notice => "You currently do not have permissions to view this section. If this is an error, please contact the system administrator.")
     end
   end

 
end
