# You can configure Blacklight from here. 
#   
#   Blacklight.configure(:environment) do |config| end
#   
# :shared (or leave it blank) is used by all environments. 
# You can override a shared key by using that key in a particular
# environment's configuration.
# 
# If you have no configuration beyond :shared for an environment, you
# do not need to call configure() for that envirnoment.
# 
# For specific environments:
# 
#   Blacklight.configure(:test) {}
#   Blacklight.configure(:development) {}
#   Blacklight.configure(:production) {}
# 

Blacklight.configure(:shared) do |config|

  config[:default_solr_params] = {
    :qt => "search",
    :per_page => 10 
  }
 
  # solr field values given special treatment in the show (single result) view
  config[:show] = {
    :html_title => "title_display",
    :heading => "title_display",
    :display_type => "itemType_facet"
  }

  # solr fld values given special treatment in the index (search results) view
  config[:index] = {
    :show_link => "title_display",
    :record_display_type => "itemType_facet"
  }

  # solr fields that will be treated as facets by the blacklight application
  #   The ordering of the field names is the order of the display
  # TODO: Reorganize facet data structures supplied in config to make simpler
  # for human reading/writing, kind of like search_fields. Eg,
  # config[:facet] << {:field_name => "format", :label => "Format", :limit => 10}
  config[:facet] = {
    :field_names => (facet_fields =  ["technology_facet",
        "originator_facet",
        "person_facet",
        "title_facet",
        "city_facet",
        "organization_facet",
        "corporateEntity_facet",
        "company_facet",
        "documentType_facet",
        "year_facet",
        "state_facet",
        "series_facet",
        "subseries_facet",
        "box_facet",
        "folder_facet",
        "donor_tags_facet"]),
    :labels => {
      "collection_facet" => "Collection",
      "technology_facet" => "Technology",
      "originator_facet" => "Author",
      "person_facet" => "Person",
      "city_facet" => "City",
      "organization_facet" => "Organization",
      "corporateEntity_facet" => "Corporate Entity",
      "company_facet" => "Company",
      "year_facet" => "Year",
      "documentType_facet" => "Document Type"
      "state_facet" => "State",
      "series_facet" => "Series",
      "subseries_facet" => "Subseries",
      "box_facet" => "Box",
      "folder_facet" => "Folder",
      "donor_tags_facet" => "Tagged by Donor",
      "archivist_tags_facet" => "Tagged by Archivist"
    },
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.     
    :limits => {
      "subject_topic_facet" => 20,
      "language_facet" => true
    }
  }

  # Have BL send all facet field names to Solr, which has been the default
  # previously. Simply remove these lines if you'd rather use Solr request
  # handler defaults, or have no facets.
  config[:default_solr_params] ||= {}
  config[:default_solr_params][:"facet.field"] = facet_fields

  # solr fields to be displayed in the index (search results) view
  #   The ordering of the field names is the order of the display 
  config[:index_fields] = {
    :field_names => [
      "text",
      "title_display",
      "date_display",
    ],
      :labels => {
        "text" => "Text:",
        "title_display" => "Title:",
        "date_display" => "Date: "
      }
  }

  # solr fields to be displayed in the show (single result) view
  #   The ordering of the field names is the order of the display 
  config[:show_fields] = {
    :field_names => [
      "access_display",
      "series_display",
      "subseries_display",
      "box_display",
      "folder_display",
      "id", 
      "donor_tags_s",
      "note_display"
    ],
    :labels => {
      "access_display" => "Access:",
      "series_display" => "Series:",
      "subseries_display"  => "Subseries:",
      "box_display" => "Box:",
      "folder_display" => "Folder:",
      "id" => "ID:",
      "donor_tags_s" => "Tagged By Donor:",
      "note_display" => "Donor Notes:"
    }
  }


  # "fielded" search configuration. Used by pulldown among other places.
  # For supported keys in hash, see rdoc for Blacklight::SearchFields
  #
  # Search fields will inherit the :qt solr request handler from
  # config[:default_solr_parameters], OR can specify a different one
  # with a :qt key/value. Below examples inherit, except for subject
  # that specifies the same :qt as default for our own internal
  # testing purposes.
  #
  # The :key is what will be used to identify this BL search field internally,
  # as well as in URLs -- so changing it after deployment may break bookmarked
  # urls.  A display label will be automatically calculated from the :key,
  # or can be specified manually to be different. 
  config[:search_fields] ||= []

  # This one uses all the defaults set by the solr request handler. Which
  # solr request handler? The one set in config[:default_solr_parameters][:qt],
  # since we aren't specifying it otherwise. 
  config[:search_fields] << {
    :key => "all_fields",  
    :display_label => 'All Fields'   
  }

  
  config[:search_fields] << {
    :key => "fulltext",
    :display_label => "Descriptions and Fulltext",
    :solr_parameters => {
      :qt => "fulltext"
    }
  }
  
  
  #config[:search_fields] << {
  #  :key =>'author',     
  #  :solr_parameters => {
  #    :"spellcheck.dictionary" => "author" 
  #  },
  #  :solr_local_parameters => {
  #    :qf => "$author_qf",
  #    :pf => "$author_pf"
  #  }
  # }

  # Specifying a :qt only to show it's possible, and so our internal automated
  # tests can test it. In this case it's the same as 
  # config[:default_solr_parameters][:qt], so isn't actually neccesary. 
  #config[:search_fields] << {
  #  :key => 'subject', 
  #  :qt=> 'search',
  #  :solr_parameters => {
  #    :"spellcheck.dictionary" => "subject"
  #  },
  #  :solr_local_parameters => {
  #    :qf => "$subject_qf",
  #    :pf => "$subject_pf"
  #  }
  #}
  
  # "sort results by" select (pulldown)
  # label in pulldown is followed by the name of the SOLR field to sort by and
  # whether the sort is ascending or descending (it must be asc or desc
  # except in the relevancy case).
  # label is key, solr field is value
  config[:sort_fields] ||= []
  config[:sort_fields] << ['relevance', 'score desc, year_sort desc, month_sort asc, title_sort asc']
  config[:sort_fields] << ['date -', 'year_sort desc, month_sort asc, day_sort asc, title_sort asc']
  config[:sort_fields] << ['date +', 'year_sort asc, month_sort asc, day_sort asc, title_sort asc']
  config[:sort_fields] << ['title', 'title_sort asc, year_sort desc, month_sort asc']
  # config[:sort_fields] << ['location', 'series_sort asc, subseries_sort asc, box_sort asc, folder_sort asc, year_sort desc, month_sort asc, title_sort asc']
  
  # If there are more than this many search results, no spelling ("did you 
  # mean") suggestion is offered.
  config[:spell_max] = 5

  # Add documents to the list of object formats that are supported for all objects.
  # This parameter is a hash, identical to the Blacklight::Solr::Document#export_formats 
  # output; keys are format short-names that can be exported. Hash includes:
  #    :content-type => mime-content-type
  config[:unapi] = {
    'oai_dc_xml' => { :content_type => 'text/xml' } 
  }
end


