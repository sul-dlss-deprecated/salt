module SaltHelper
  
   
  # we have 4 different scenerios: 1. gallery (no grouping), 2. gallery (with facet grouping), 3. list (no grouping) 4. list (w/ facet grouping)
  def index_results_box
      facet_name = grouping_facet
      facet_name.nil? ? index_ungrouped_results : index_grouped_results(facet_name)
  end
 
 
  # this groups the documents by facet and displays them in the box.
  def index_grouped_results(facet_name)
   html = ""
   groupings = @response.docs.group_by {|d| d[facet_name];  }
   groupings.each do |key, value|   
     unless value.nil?
       html <<  render_partial('catalog/_index_partials/group',  {:docs => value, :facet_name => facet_name, :facet_value => key, :view_type => viewing_context } )
      end
    end
     return html.html_safe
  end

  # returns the results ungrouped
  def index_ungrouped_results
    render_partial('catalog/_index_partials/group', {:docs => @response.docs, :facet_name => nil, :facet_value => nil, :view_type => viewing_context } )
  end

  # convenience method to render partials
  def render_partial(partial, locals= {})
    render(:partial => partial, :locals => locals )
  end
  
  # returns the css class name depening on the params[:view] mode
  def index_results_class
    viewing_context == 'list' ?  "list_index" : "gallery_index"
  end

  # conveninece method to return the view context
  def viewing_context
    params[:view] ||= "gallery"  
    params[:view] == 'list' ?  "list" : "gallery"
  end
  
  
  # looks at sort params sent to solr and returns a display label
  def grouping_facet
    fields = Hash[sort_fields]
    case h(params[:sort])
    when fields['date -']
      'year_facet'
    when fields['date +']
      'year_facet'
  #  when fields['location']
  #    'subseries_facet'
    else
      nil
    end
  end
  
  def grouped_result_count(response, facet_name=nil, facet_value=nil)
     if facet_name && facet_value
       facet = response.facets.detect {|f| f.name == facet_name}
       facet_item = facet.items.detect {|i| i.value == facet_value} if facet
       count = facet_item ? facet_item.hits : 50
     else
       count = response.docs.length
     end
     pluralize(count, 'document')
   end
  
  # takes two strings and returns HTML for the group heading. 
  def display_group_heading(facet_name=nil, facet_value=nil)
    facet_value.is_a?(Array) ? facet_value = facet_value.first : facet_value = facet_value
    html =  "<h3>#{facet_value.html_safe if facet_value}<em>&nbsp;&nbsp;&nbsp;#{ grouped_result_count(@response, facet_name, facet_value)}</em></h3>".html_safe
    return html
  end
  
  # takes string and returns id without druid: prefix
  def remove_druid_prefix(druid)
    return druid.gsub("druid:", "")
  end
  
  # returns image tag for an asset thumbnail
  def thumb_tag(id)
    id.gsub!("druid:", "")
    "<img src=#{url_for(:action => 'show', :controller => 'asset', :id => id, :format => :jpg )} alt=\"druid:#{id}\"/>".html_safe
    
  end
  
 # returns "This document refers to" if it's a show action, "Limit Your Search" if its index
 def facets_display_heading()
   action_name == "show" ? "This Document Refers To" : "Limit Your Search"
 end
  
 def facets_toggle
   if action_name == "show"
     javascript_includes << "facet_toggle.js"
      javascript_includes << "flipbook.js"
   end
   return javascript_includes 
 end
 
 # returns the donor notes as unescaped html 
 def display_donor_notes
     solr_fname = "notes_display"
     result = "<dt class='blacklight-#{solr_fname.parameterize}'>#{render_document_show_field_label :field => solr_fname}</dt>"
     result << "<dd class='blacklight-#{ solr_fname.parameterize }'>"
     @document[solr_fname] ? notes = @document[solr_fname].join("<br/><br/>") : notes = ""
     unless notes.nil?
       Array.wrap(notes).each { |n| result << n  }
     end
     return result.html_safe
 end
 
 #
 # Pass in an RSolr::Response. Displays the "showing X through Y of N" message. 
  def render_salt_pagination_info(response, options = {})
      start = response.start + 1    
      response.rows != 0 ? per_page = response.rows : per_page = 1  
      current_page = (response.start.to_f / per_page.to_f ).ceil + 1
      num_pages = (response.total.to_f / per_page.to_f).ceil
      total_hits = response.total

      start_num = format_num(start)
      end_num = format_num(start + response.docs.length - 1)
      total_num = format_num(total_hits)

      entry_name = options[:entry_name] ||
        (response.empty?? 'entry' : response.docs.first.class.name.underscore.sub('_', ' '))

      if num_pages < 2
        case response.docs.length
        when 0; "No #{h(entry_name.pluralize)} found".html_safe
        when 1; "Displaying <b>1</b> #{h(entry_name)}".html_safe
        else;   "Displaying <b>all #{total_num}</b> #{entry_name.pluralize}".html_safe
        end
      else
        "<span id='salt_pagination_info'><b>#{start_num} - #{end_num}</b> of <b>#{total_num}</b></span>".html_safe
      end
  end
 
 #
 # Takes a solr document and returns documents that are in the document's folder. 
 def folder_siblings(document=@document)
    @folder_siblings_cache ||= {}
 
    return @folder_siblings_cache[document[:id]] if @folder_siblings_cache[document[:id]] 

    folder_search_params = {:rows => 1000}
    if document[:series_facet]   
      folder_search_params[:fq] = ["series_facet:\"#{return_first(document[:series_facet])}\""]
      if document[:box_facet]
        folder_search_params[:fq] << "box_facet:\"#{return_first(document[:box_facet])}\""
        if document[:folder_facet]
          folder_search_params[:fq] << "folder_facet:\"#{return_first(document[:folder_facet])}\""
        end
      end

      response, documents = get_search_results(folder_search_params, {})

      @folder_siblings_cache[document[:id]] = documents
    else 
      []
    end
  end

 
 #convenience method for returning first value of a facet
 def return_first(a_facet=[])
   value = nil
   a_facet.is_a?(Array) ? value = a_facet.first : value = a_facet
   return value
 end
 
  # Takes a SOLR facet and turns it into a link to be added to the document folder box. 
  def link_to_multifacet( facet, prefix, args={} )
     unless facet.nil? 
       facet_params = {}
       options = {}
       args.each_pair do |k,v|
         if k == :options
           options = v
         else
           facet_params[:f] ||= {}
           facet_params[:f][k] ||= []
           v = v.instance_of?(Array) ? v.first : v
           facet_params[:f][k].push(v)
         end
       end
       link_to("#{prefix}#{facet}", catalog_index_path(facet_params), options).html_safe
     end
   end
   
end
