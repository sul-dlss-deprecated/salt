require 'open-uri'

module Stanford
  
  class Indexer
    
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
      salt_doc = Stanford::SaltDocument.new(pid, { :repository => @repository })
      index(salt_doc)
    end
        
private
    
    # This method takes the SaltDocument and adds it to the Solr index. 
    def index(salt_doc)
       @solr.add(salt_doc.to_solr)
       @solr.update :data => '<commit/>'
    end
  
    
  end #class
end #module