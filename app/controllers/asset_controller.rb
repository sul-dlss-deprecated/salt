require 'blacklight/catalog'

class AssetController < ApplicationController  

   include Blacklight::Catalog
  
  
  def show
    
   
    (  @response, @document = get_solr_response_for_doc_id("druid:#{params[:id]}"))  if !user_signed_in?  
  
    @asset = Asset.new(params[:id])
    
    respond_to do |format|
      format.html {send_data(@asset.get_pdf, :type => 'application/pdf')}
      format.pdf   {send_data(@asset.get_pdf, :type => 'application/pdf')}
      format.jpg  {send_data(@asset.get_thumbnail, :type => :jpg, :disposition => 'inline')}
    end
  rescue Blacklight::Exceptions::InvalidSolrID
      flash[:notice]= "You do not have sufficient access privileges to see this asset, which has been marked private."
      redirect_to(:controller => 'catalog', :action => 'index', :q => nil , :f => nil) and return false      
  end
  
  def show_page
    (  @response, @document = get_solr_response_for_doc_id("druid:#{params[:id]}"))  if !user_signed_in?  
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

end 