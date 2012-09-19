module AuthenticationHelper
  
  def apply_special_parameters_for_a_fulltext_query solr_parameters, user_parameters
    solr_parameters[:qt] = 'fulltext' if user_parameters[:search_field] == 'fulltext'
  end

  def apply_gated_discovery solr_parameters, user_parameters
    unless user_signed_in? or request.env["REMOTE_ADDR"] == FLIPBOOK_IP  or  request.env["REMOTE_ADDR"] == DJATOKA_IP
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "public_b:true"
    end
  end
  
end
