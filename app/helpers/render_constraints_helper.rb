

module RenderConstraintsHelper
 
  require "#{Blacklight.root}/app/helpers/render_constraints_helper"
 
  
  def render_constraints_query(localized_params = params)
    # So simple don't need a view template, we can just do it here.
    if (!localized_params[:q].blank?)
      label = nil
      
      content = "<span class='search_terms'><span class='search_label'>Your Search: </span>"
      
      terms = get_search_breadcrumb_terms(localized_params[:q])
   
      
      terms.each_with_index do |v,k|
        
        new_query = terms.dup
        new_query.delete_at(k)
        
        content << render_constraint_element(label , v, :classes => ["query"], :remove => catalog_index_path(localized_params.merge(:q=>new_query.join(" "), :action=>'index'))) 
      end
      
      return content.html_safe
    
    else
      "</span>".html_safe
    end
  end
  
  def render_constraints_filters(localized_params = params)
     return "".html_safe unless localized_params[:f]
     content = "<div class='facet_terms'><span>Limited To: </span>"
     localized_params[:f].each_pair do |facet,values|
        values.each do |val|
           content << render_constraint_element( facet_field_labels[facet],
                  val, 
                  :remove => catalog_index_path(remove_facet_params(facet, val, localized_params)),
                  :classes => ["filter", "filter-" + facet.parameterize] 
                ) + "\n"                 					            
				end
     end 
     content << "</div>"
     return content.html_safe    
  end
  
  
 
  
  
  # taken from the searchworks helper. breaks searches into terms. 
   def get_search_breadcrumb_terms(q_param)
      if q_param.scan(/"([^"\r\n]*)"/).length > 0
        q_arr = []
        old_q = q_param.dup
        q_param.scan(/"([^"\r\n]*)"/).each{|t| q_arr << "\"#{h(t)}\""}
        q_arr.each do |l|
          old_q.gsub!(l,'')
        end
        unless old_q.blank?
          old_q.split(' ').each {|q| q_arr << h(q) }
        end
      q_arr
      else
         q_arr = q_param.split(' ')
      end
    end
  
  
end
