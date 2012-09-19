# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController  
  
  layout "salt"

  include Blacklight::SolrHelper
  include Blacklight::Catalog
  include SaltHelper
  include AuthenticationHelper

  self.solr_search_params_logic << :apply_gated_discovery
  self.solr_search_params_logic << :apply_special_parameters_for_a_fulltext_query

  helper_method :get_search_results
  
  before_filter :add_styles


   # get search results from the solr index
    def index
      
      delete_or_assign_search_session_params
      
      extra_head_content << view_context.auto_discovery_link_tag(:rss, url_for(params.merge(:format => 'rss')), :title => "RSS for results")
      extra_head_content << view_context.auto_discovery_link_tag(:atom, url_for(params.merge(:format => 'atom')), :title => "Atom for results")
      
      (@response, @document_list) = get_search_results 
      
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
     
      @response, @document = get_solr_response_for_doc_id(params[:id])
      folder_siblings(@document)

  
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
      redirect_to("/") and return false
    end

private

  def add_styles
    extra_head_content << view_context.stylesheet_link_tag("salt")
  end

end 
