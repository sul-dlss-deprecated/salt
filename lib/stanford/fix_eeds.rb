require 'rubygems'
require 'rest-client'
require 'open-uri'
require 'nokogiri'
require 'rsolr'

module Stanford
  
  class FixEeds
    
    attr_accessor :queue
    attr_accessor :repository
    attr_accessor :solr
    
    def initialize      
      @solr = SolrDocument.connection
      @repository = Stanford::Repository.new()
      @queue = @repository.initialize_queue
    end #def initalize
    
    # This method processes a queue of items
    def process_queue
      @queue.each do |pid|
        process_item(pid)
      end
    end
    
    # This method processes a single item.
    def process_item(pid)
      
      newXML = Nokogiri::XML("<document>")
      newFacets = Nokogiri::XML::Node.new("facets", newXML)
      
      
      xml = Nokogiri::XML(@repository.get_datastream(pid, 'extracted_entities'))
      xml.search("//facet").each do |f|
        case f["type"]
        when "city", "person", "company", "provinceorstate", "organization"
          newFacets << f
        end
      end
      
      newXML.root << newFacets
      
      uri = URI.parse("http://fedoraAdmin:fedoraAdmin@salt-dev.stanford.edu:8080" + '/objects/' + pid + '/datastreams/extracted_entities'  ) 
      res = RestClient.put uri.to_s, newXML.to_xml, :content_type => "application/xml"
      
      
    end

    
  end #class
end #module