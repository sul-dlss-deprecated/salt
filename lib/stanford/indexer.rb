require 'open-uri'

module Stanford
  
  class Indexer
    
    attr_accessor :queue
    attr_accessor :repository
    attr_accessor :solr
    
    # takes a list of druids. If empty, it gets all the druids from the repository. 
    def initialize(druids=[])      
      @solr = SolrDocument.connection
      @repository = Stanford::Repository.new()
      
      druids.length < 1 ? @queue = @repository.initialize_queue : @queue = druids
  
    end #def initalize
    
    # This method processes a queue of items
    def process_queue
      log_message("Processing Queue")
      @queue.each do |pid|
        process_item(pid)
      end
      log_message("Queue processing completed.")
    end
    
    # This method processes a single item.
    def process_item(pid)
      log_message("Processing item #{pid}")
      salt_doc = Stanford::SaltDocument.new(pid, { :repository => @repository })
      index(salt_doc)
    end
        
private
    
    # This method takes the SaltDocument and adds it to the Solr index. 
    def index(salt_doc)
       @solr.add(salt_doc.to_solr)
       @solr.update :data => '<commit/>'
    end
  

     def log_message(msg)
       if  defined?(Rails) == "constant" 
         Rails.logger.info "Stanford::Indexer : #{msg} "  
       end
     end
    
  end #class
end #module