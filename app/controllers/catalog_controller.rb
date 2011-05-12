require 'blacklight/catalog'

class CatalogController < ApplicationController  

  include Blacklight::Catalog
  include SaltHelper

   # get search results from the solr index
    def index
      
      delete_or_assign_search_session_params
      
      extra_head_content << view_context.auto_discovery_link_tag(:rss, url_for(params.merge(:format => 'rss')), :title => "RSS for results")
      extra_head_content << view_context.auto_discovery_link_tag(:atom, url_for(params.merge(:format => 'atom')), :title => "Atom for results")
      extra_head_content << view_context.auto_discovery_link_tag(:unapi, unapi_url, {:type => 'application/xml',  :rel => 'unapi-server', :title => 'unAPI' })
      
      if user_signed_in?  
        (@response, @document_list) = get_search_results(:qt => "authed_search") 
      else 
        (@response, @document_list) = get_search_results
      end
      
      @filters = params[:f] || []
      search_session[:total] = @response.total unless @response.nil?
      
      respond_to do |format|
        format.html { save_current_search_params }
        format.rss  { render :layout => false }
        format.atom { render :layout => false }
      end
    end



    # get single document from the solr index
    def show
     
      extra_head_content << view_context.auto_discovery_link_tag(:unapi, unapi_url, {:type => 'application/xml',  :rel => 'unapi-server', :title => 'unAPI' })
      
      user_signed_in? ? ( @response, @document = get_solr_response_for_doc_id(params[:id], :qt => "authed_document") ) : (@response, @document = get_solr_response_for_doc_id(params[:id]) )
         
      respond_to do |format|
        format.html {setup_next_and_previous_documents}

        # Add all dynamically added (such as by document extensions)
        # export formats.
        @document.export_formats.each_key do | format_name |
          # It's important that the argument to send be a symbol;
          # if it's a string, it makes Rails unhappy for unclear reasons. 
          format.send(format_name.to_sym) { render :text => @document.export_as(format_name), :layout => false }
        end
        
      end
    rescue Blacklight::Exceptions::InvalidSolrID
      flash[:notice]= "You do not have sufficient access privileges to read this document, which has been marked private."
      redirect_to(:action => 'index', :q => nil , :f => nil) and return false
    end

end 
