# -*- coding: utf-8 -*-
#
# Methods added to this helper will be available to all templates in the hosting application
#
module BlacklightHelper
  
   
  require "#{Blacklight.root}/app/helpers/blacklight_helper"
   

   
  # Used in the show view for setting the main html document title
  def document_show_html_title
    Array.wrap(@document[blacklight_config.show.html_title]).first
  end
   
   def render_document_index_label doc, opts
     label = nil
     label ||= doc[opts[:label]] if opts[:label].instance_of? Symbol
     label ||= opts[:label].call(doc, opts) if opts[:label].instance_of? Proc
     label ||= opts[:label] if opts[:label].is_a? String
     label ||= doc.id
   end
   
   # link_to_document(doc, :label=>'VIEW', :counter => 3)
   # Use the catalog_path RESTful route to create a link to the show page for a specific item. 
   # catalog_path accepts a HashWithIndifferentAccess object. The solr query params are stored in the session,
   # so we only need the +counter+ param here. We also need to know if we are viewing to document as part of search results.
   
   # This is an override because the assset helper does not use druid:. We need to add the druid: to the URL for the catalog controller. 
   def link_to_document(doc, opts={:label=>Blacklight.config[:index][:show_link].to_sym, :counter => nil, :results_view => true})
     label = render_document_index_label(doc, opts)
     doc[:id].include?("druid:") ? doc_id = doc[:id] : doc_id = "druid:#{doc[:id]}"
     link_to_with_data(label, catalog_path(doc_id), {:method => :put, :class => label.first.parameterize, :data => opts}).html_safe
   end   
  
    def render_document_heading(*args)
      options = args.extract_options!
      if args.first.is_a? SolrDocument
        document = args.shift
        tag = options[:tag]
      else
        document = @document
        tag = args.first || options[:tag]
      end

      tag ||= :h4

      document_heading = Array.wrap(document[blacklight_config.show.heading]).first || document.id
      content_tag(tag, document_heading, :itemprop => "name")
    end
   
   def application_name
     'SALT (Self Archiving Legacy Toolkit)'
   end
   
   
end
