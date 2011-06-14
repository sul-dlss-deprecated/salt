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
    
    def initialize(file)
      
      @repository = Stanford::Repository.new()
      @processed_druids = []
      if File.exists?(file)
        @xmlfile = file
      else 
        raise "Need to provide xml file to process"
      end
    end
   
   def process_document
     xml = Nokogiri::XML(open(@xmlfile))
     nodes =  xml.search("//rdf:RDF/*")
     previous = nil
     nodes.each do |node|
        previous =  process_node(node, previous)
     end
     update_fedora(previous)  #make sure the last node in the XML document was updated
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
             @repository.update_datastream(druid, "zotero", xml.to_xml)
             @processed_druids << druid
        end
      end
    end
     
      private

      def log_message(msg)
        if  defined?(Rails) == "constant" 
          Rails.logger.info msg    
        end
      end
  
    
  end
end