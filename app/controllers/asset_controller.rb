require 'blacklight/catalog'

# This controller is used to get document assets (pdfs, jp2000s, tei xml, ect ) from the asset server. 
# A solr q. has to be done first in order to determine if the asset is tagged as public or private. If the user
# is not logged in and the asset is private, the req. handler should not return results for the get_solr_response_for_doc_id and
# instead return a  Blacklight::Exceptions::InvalidSolrID error. 
class AssetController < ApplicationController  

  include Blacklight::Catalog
  include AssetHelper
  include AuthenticationHelper

  self.solr_search_params_logic << :apply_gated_discovery
  
  
  def show
    # some zotero urls still have druids in the druid name. 
    if params[:id].include?("druid:")
        redirect_to :action => 'show', :id => params[:id].gsub("druid:", ''), :format => request[:format] and return true
    end  
      
    
  	@response, @document = get_solr_response_for_doc_id("druid:#{params[:id]}")  

 
    @asset = Asset.new(params[:id], params[:page])
    
    respond_to do |format|
      format.html {render :layout => false}
      format.pdf   {send_data(@asset.get_pdf, :type => 'application/pdf')}
      format.jpg  {send_data(@asset.get_thumbnail, :type => :jpg, :disposition => 'inline')}
      format.flipbook { send_data(@asset.get_flipbook, :disposition => 'inline', :type => 'text/html') }
      format.json { send_data(@asset.get_json, :type => 'application/json') }
      format.jp2 { send_data(@asset.get_page_jp2, :type => 'image/jp2', :disposition => 'inline')} 
    end
    
  rescue Blacklight::Exceptions::InvalidSolrID
      flash[:notice]= "You do not have sufficient access privileges to see this asset, which has been marked private."
      redirect_to("/") and return false
  end
  
  def show_page
    
     @response, @document = get_solr_response_for_doc_id("druid:#{params[:id]}")


     @asset = Asset.new(params[:id], params[:page] )
     
     respond_to do |format|
       format.html { send_data(@asset.get_page_jp2, :type => 'image/jp2', :disposition => 'inline')} # don't know why. just send jp2000. 
       format.xml { send_data(@asset.get_page_xml, :type => 'application/xml', :disposition => 'inline')}
       format.jp2 { send_data(@asset.get_page_jp2, :type => 'image/jp2',  :disposition => 'inline')}       
     end
     
  rescue Blacklight::Exceptions::InvalidSolrID
      flash[:notice]= "You do not have sufficient access privileges to see this asset, which has been marked private."
      redirect_to("/") and return false
  end

  def get_flipbook_asset
    respond_to do |format|
      format.css { send_data(Asset.get_flipbook_asset(params[:file], '.css'), :type => 'text/css', :disposition => 'inline')}
      format.js { send_data(Asset.get_flipbook_asset(params[:file], '.js'), :type => 'application/x-javascript', :disposition => 'inline') }
      format.html { send_data(Asset.get_flipbook_asset(params[:file], '.js'), :type => 'application/x-javascript', :disposition => 'inline') }
      format.png { send_data(Asset.get_flipbook_asset(params[:file], '.png'), :type => 'image/png', :disposition => 'inline') }
    end
  end


end 
