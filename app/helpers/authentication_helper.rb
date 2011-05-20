module AuthenticationHelper
  


  # solr_search_params_logic methods take two arguments
  # @param [Hash] solr_parameters a hash of parameters to be sent to Solr (via RSolr)
  # @param [Hash] user_parameters a hash of user-supplied parameters (often via `params`)
  def show_authenticated_records solr_parameters, user_parameters
    # add a new solr facet query ('fq') parameter that limits results to those with a 'public_b' field of 1 
    solr_parameters[:qt] = 'authed_search'
  end
  
  # solr_search_params_logic methods take two arguments
   # @param [Hash] solr_parameters a hash of parameters to be sent to Solr (via RSolr)
   # @param [Hash] user_parameters a hash of user-supplied parameters (often via `params`)
   def show_authenticated_fulltext_records solr_parameters, user_parameters
     # add a new solr facet query ('fq') parameter that limits results to those with a 'public_b' field of 1 
     solr_parameters[:qt] = 'authed_fulltext'
   end
  
   # solr_search_params_logic methods take two arguments
    # @param [Hash] solr_parameters a hash of parameters to be sent to Solr (via RSolr)
    # @param [Hash] user_parameters a hash of user-supplied parameters (often via `params`)
    def show_fulltext_records solr_parameters, user_parameters
      # add a new solr facet query ('fq') parameter that limits results to those with a 'public_b' field of 1 
      solr_parameters[:qt] = 'fulltext'
    end
  
end
