module AuthenticationHelper
  
  def apply_special_parameters_for_a_fulltext_query solr_parameters, user_parameters
    solr_parameters[:qt] = 'fulltext' if user_parameters[:search_field] == 'fulltext'
  end

  def apply_gated_discovery solr_parameters, user_parameters
    unless user_signed_in? or request.env["REMOTE_ADDR"] == Settings.flipbook.ip  or  request.env["REMOTE_ADDR"] == Settings.djatoka.ip
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "public_b:true"
    end
  end
  
  def get_solr_doc_with_gated_discovery(doc_id, solr_parameters={})
    unless user_signed_in? or request.env["REMOTE_ADDR"] == Settings.flipbook.ip  or  request.env["REMOTE_ADDR"] == Settings.djatoka.ip
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "public_b:true"
    end
    get_solr_response_for_doc_id(doc_id, solr_parameters)
  end
end
