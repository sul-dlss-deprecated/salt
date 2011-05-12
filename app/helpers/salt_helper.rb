module SaltHelper
  
  
  # we have 4 different scenerios: 1. gallery (no grouping), 2. gallery (with facet grouping), 3. list (no grouping) 4. list (w/ facet grouping)
  def index_results_box
      facet_name = grouping_facet
      facet_name.nil? ? index_ungrouped_results : index_grouped_results(facet_name)
  end


  # this groups the documents by facet and displays them in the box.
  def index_grouped_results(facet_name)
    @response.docs.group_by {|d| d.get(facet_name)}.each do |grouping|
      render_partial('catalog/_index_partials/group', {:docs => grouping[1], :facet_name => facet_name, :facet_value => grouping[0].to_s, :view_type => viewing_context } )
    end 
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
    when fields['location']
      'series_facet'
    else
      nil
    end
  end
  
  def grouped_result_count(response, facet_name=nil, facet_value=nil)
     if facet_name && facet_value
       facet = response.facets.detect {|f| f.name == facet_name}
       facet_item = facet.items.detect {|i| i.value == facet_value} if facet
       count = facet_item ? facet_item.hits : 0
     else
       count = response.docs.total
     end
     pluralize(count, 'document')
   end
  
  
  
end
