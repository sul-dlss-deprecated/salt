require 'open-uri'

module Stanford
  
  class Indexer
    
    attr_accessor :queue
    attr_accessor :repository
    attr_accessor :solr
    attr_accessor :zotero_ingest
    
    # takes a list of druids and optionally a ZoteroIngest object for logging. If empty, it gets all the druids from the repository.
    def initialize(druids=[],  zotero_ingest = nil)      
      @solr = SolrDocument.connection
      @repository = Stanford::Repository.new()
      
      druids.length < 1 ? @queue = @repository.initialize_queue : @queue = druids
  
       unless zotero_ingest.nil?
          @zotero_ingest = zotero_ingest
        end
      
  
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
      log_message("Indexing item #{pid}")
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
         unless @zotero_ingest.nil? 
           ZoteroIngest.update(zotero_ingest.id, { :message => zotero_ingest.message << "[#{Time.now.strftime("%Y-%m-%d_%H-%M-%s")}] : #{msg}\n"  } )
         end
       end
     end
    
  end #class
end #module