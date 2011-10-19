require 'rubygems'
require 'nokogiri'
require 'lib/stanford/repository'
require 'json'
require 'tempfile'


module Stanford
  class ZoteroParser
    
    attr_accessor :xmlfile
    attr_accessor :repository
    attr_accessor :processed_druids
    attr_accessor :zotero_ingest
    
    # intalialize with a string pointing to a file to be processed and optionally a ZoteroIngest object for logging
    def initialize(file, zotero_ingest = nil)
      
      raise ArgumentError.new("Need to provide xml file to process") if !File.exists?(file)
      
      @xmlfile = file
      @repository = Stanford::Repository.new()
      @processed_druids = []
      
      
      case zotero_ingest
      when ZoteroIngest
          @zotero_ingest = zotero_ingest
      else
          ArgumentError.new("The zotero_ingest parameter needs to be a ZoteroIngest object.")
      end
      
   
    end
   
   def process_document
     update_record(:ingest_start, Time.now)
     xml = Nokogiri::XML(open(@xmlfile))
     nodes =  xml.search("//rdf:RDF/*")
     previous = nil
     nodes.each do |node|
        previous =  process_node(node, previous)
     end
     update_fedora(previous)  #make sure the last node in the XML document was updated
     update_record(:ingest_end, Time.now)
     return true
   end
   
   
   # accecpts a nokogiri node and a nokogiri document. If the node name is a memo, that will be added to the xml document.
   # otherwise, the xml document will be added to fedora and the node will be inserted into its own xml document and returned.
   
   def process_node(node, previous)
     if node.name == "Memo"
        previous.root << node
        return previous
     else
        
        unless previous.nil?
          update_fedora(previous) #update Fedora with the pervious node and move on
        end
        
        string = <<EOF
         <rdf:RDF
           xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
           xmlns:dc="http://purl.org/dc/elements/1.1/"
           xmlns:dcterms="http://purl.org/dc/terms/"
           xmlns:bib="http://purl.org/net/biblio#"
           xmlns:z="http://www.zotero.org/namespaces/export#"
           xmlns:link="http://purl.org/rss/1.0/modules/link/"
           xmlns:foaf="http://xmlns.com/foaf/0.1/"
           xmlns:vcard="http://nwalsh.com/rdf/vCard#"
           xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/">
           #{node.to_xml}
           </rdf:RDF>
EOF

        rdf = Nokogiri::XML(string)
        return rdf
     end
   end
      
    
    # takes XML nokogiri object and updates it to fedora
    def update_fedora(xml)
      unless xml.nil?        
        druid = xml.search("//rdf:RDF/*[@rdf:about]").first["about"].gsub("https://saltworks.stanford.edu/documents/","").gsub("/downloads?download_id=document.pdf","")
        unless druid.nil?
             log_message("Updating #{druid} at #{@repository.base}")
             response = @repository.update_datastream(druid, "zotero", xml.to_xml)
             
             response == Net::HTTPSuccess ?  @processed_druids << druid : log_message("#{druid} -- #{response}")
               
        end
      end
    end
     
      private


      def log_message(msg)
        if  defined?(Rails) == "constant" 
          Rails.logger.info msg    
          unless @zotero_ingest.nil? 
       #     ZoteroIngest.update(zotero_ingest.id, { :message => zotero_ingest.message << "[#{Time.now.strftime("%Y-%m-%d_%H-%M-%s")}] : #{msg}\n"  } )
          end
        end
      end
  
      def update_record(field, msg)
        unless @zotero_ingest.nil?
           ZoteroIngest.update(@zotero_ingest.id, { field.to_sym => msg  } )
        end
      end
   end
 
end