require 'blacklight/catalog'

class AssetController < ApplicationController  

   include Blacklight::Catalog
   include AssetHelper
  
  
  def show

    unless user_signed_in?
       unless  request.env["REMOTE_ADDR"] == FLIPBOOK_IP  or  request.env["REMOTE_ADDR"] == DJATOKA_IP
      	(  @response, @document = get_solr_response_for_doc_id("druid:#{params[:id]}"))  
       end
    end 
 
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
      redirect_to(:controller => 'catalog', :action => 'index', :q => nil , :f => nil) and return false      
  end
  
  def show_page
    
    unless user_signed_in?
       unless  request.env["REMOTE_ADDR"] == FLIPBOOK_IP  or  request.env["REMOTE_ADDR"] == DJATOKA_IP           
        (  @response, @document = get_solr_response_for_doc_id("druid:#{params[:id]}"))
       end
    end
     

     @asset = Asset.new(params[:id], params[:page] )
     
     respond_to do |format|
       format.html { send_data(@asset.get_page_jp2, :type => 'image/jp2', :disposition => 'inline')} # don't know why. just send jp2000. 
       format.xml { send_data(@asset.get_page_xml, :type => 'application/xml', :disposition => 'inline')}
       format.jp2 { send_data(@asset.get_page_jp2, :type => 'image/jp2',  :disposition => 'inline')}       
     end
     
  rescue Blacklight::Exceptions::InvalidSolrID
      flash[:notice]= "You do not have sufficient access privileges to see this asset, which has been marked private."
      redirect_to(:controller => 'catalog', :action => 'index', :q => nil , :f => nil) and return false  
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
