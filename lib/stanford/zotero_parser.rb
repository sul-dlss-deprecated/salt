require 'rubygems'
require 'nokogiri'
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
     nodes =  xml.search("//rdf:RDF/*", "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
     nodes.reject { |node| node.name == "Memo" }.each do |node|
        doc = process_node(node)
        next if doc.nil?
        druid = figure_out_the_druid_for_the_doc(doc)
        next if druid.nil?
        update_fedora(doc, druid)
     end
     update_record(:ingest_end, Time.now)
     return true
   end
   
   
   # Convert a bib node into a document, and include any Memos from the node's document context in the generated document
   def process_node(node)

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

        node.xpath('dcterms:isReferencedBy/@rdf:resource', "dcterms" =>"http://purl.org/dc/terms/", "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#").each do |ref|
          rdf.root << node.xpath('//bib:Memo[@rdf:about="%s"]' % [ref.text], "bib" => "http://purl.org/net/biblio#", "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
        end

        return rdf
   end
    
    def figure_out_the_druid_for_the_doc doc
      about = doc.xpath("//rdf:RDF/*[@rdf:about]/@rdf:about", "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#").first
      # if rdf:about has something that looks like a druid, take it!
      if about =~ /([a-z]{2}\d{3}[a-z]{2}\d{4})/
        return "druid:#{$1}" # first match
      end

      # look in the identifiers
      doc.xpath('//dc:identifier/dcterms:URI/rdf:value', "dc" => "http://purl.org/dc/elements/1.1/", "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "dcterms" =>"http://purl.org/dc/terms/").each do |v|
        if v.text =~ /([a-z]{2}\d{3}[a-z]{2}\d{4})/
          return "druid:#{$1}"
        end
      end
      
      # look in dc:description???
      doc.xpath('//dc:description', "dc" => "http://purl.org/dc/elements/1.1/").each do |v|
        if v.text =~ /([a-z]{2}\d{3}[a-z]{2}\d{4})/
          return "druid:#{$1}"
        end
      end

    end  
    
    # takes XML nokogiri object and updates it to fedora
    def update_fedora(xml, druid)
      log_message("Updating #{druid} at #{@repository.base}")

      begin
        response = @repository.update_datastream(druid, "zotero", xml.to_xml)
       
        @processed_druids << druid
      rescue Rubydora::FedoraInvalidRequest => e
        log_message("#{druid} -- #{e.inspect}")
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
