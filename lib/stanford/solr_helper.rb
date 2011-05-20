module MyApplication::SolrHelper::Authorization
#  You could also add the logic here
#  def self.included base
#    base.solr_search_params_logic << :show_only_public_records
#  end

  # solr_search_params_logic methods take two arguments
  # @param [Hash] solr_parameters a hash of parameters to be sent to Solr (via RSolr)
  # @param [Hash] user_parameters a hash of user-supplied parameters (often via `params`)
  def show_only_public_records solr_parameters, user_parameters
    # add a new solr facet query ('fq') parameter that limits results to those with a 'public_b' field of 1 
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << 'public_b:1'
  end
end
