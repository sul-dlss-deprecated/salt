require 'rubygems'
require 'rsolr'
require 'rsolr-ext'
require 'json'

module Stanford
  
  #this script is used to verify that the proper values are in Solr.
  
  class SolrCheckr
  
  
    attr_accessor :zotero_xml
    attr_accessor :zotero_ingest
    attr_accessor :solr
    attr_accessor :report
    
    def initialize(zotero_xml, zotero_ingest = nil)
        if File.exists?(zotero_xml)
          @zotero_xml = zotero_xml
        else 
          raise "Need to provide xml file to process"
        end
        
        zotero_ingest ?    @zotero_ingest = zotero_ingest : @zotero_ingest = nil
            
        @solr = SolrDocument.connection
        @report = File.open("log/data_check_#{Time.now}.txt", "w")
    end
    
    def check_documents
      update_record(:check_start, Time.now)
      zotero_docs = generate_zotero_hash
      zotero_docs.each do |zotero_doc|
        solr_response = get_solr_doc(zotero_doc["druid"])
        if solr_response and solr_response["response"]["docs"] and solr_response["response"]["docs"].first
          check_document( zotero_doc, solr_response["response"]["docs"].first )
        end
      end
      update_record(:check_end, Time.now)
    end
        
    def check_document(zotero_doc = {}, solr_doc = {})    
        @report << "#{zotero_doc['druid']}\t"
       
       
       

         ["title_s", "title_display", "title_t"].each { |v| check_values(v, zotero_doc["title"], solr_doc[v] ) }
         ["originator_facet", "originator_s", "originator_t"].each {|v| check_values(v, zotero_doc["originator"], solr_doc[v] )   }
         ["documentType_facet", "documentType_s", "documentType_display", "documentType_t"].each {|v|  check_values(v, zotero_doc["document_type"], solr_doc[v] ) }
         ["documentSubType_facet", "documentSubType_s", "documentSubType_display", "documentSubType_t"].each {|v| check_values(v, zotero_doc["document_subtype"], solr_doc[v] )  }
         ["containingWork_facet", "containingWork_s", "containingWork_display", "containingWork_t"].each {|v| check_values(v, zotero_doc["containing_work"], solr_doc[v] ) }
         ["corporateEntity_facet", "corporateEntity_t"].each { |v|  check_values(v, zotero_doc["corporate_entity"], solr_doc[v] )  }
         ["extent_s", "extent_t", "extent_display"].each {|v| check_values(v, zotero_doc["extent"], solr_doc[v] )  }
         ["language_facet", "language_s", "language_display", "language_t"].each {|v| check_values(v, zotero_doc["language"], solr_doc[v] )  }
         ["abstract_s", "abstract_t", "abstract_display"].each {|v| check_values(v, zotero_doc["abstract"], solr_doc[v] )  }
         ["EAFHardDriveFileName_display", "EAFHardDriveFileName_t", "EAFHardDriveFileName_s"].each {|v| check_values(v, zotero_doc["EAF_hard_drive_file_name"], solr_doc[v] )  }

       @report << "\n"
    rescue ArgumentError => e
       puts e
       @report << "#{e}\t"
    rescue Timeout::Error => e
      @report << "#{e}\t"
      sleep 10
    end
        
private

  # this method generates the hash from JSON using the PHP script and ensures key values are present
    def generate_zotero_hash
      json = JSON(`/usr/bin/env php lib/stanford/zotero_to_json.php #{@zotero_xml}`)
      return json
    end
    
    def get_solr_doc(druid, count=0)
      if count < 5
        return solr.get('select', :params => { :q => "id:#{druid.gsub(':', '\:')}"}, :wt => :json) 
      else
        return nil
      end
    rescue Timeout::Error => e # for random timeot error, let's try and wait them out. 
      sleep(5)
      count += 1 
      get_solr_doc(druid, count)
    rescue Errno::ETIMEDOUT => e # for random timeot error, let's try and wait them out. 
        sleep(5)
        count += 1 
        get_solr_doc(druid, count)
      rescue => e
        @report << e.backtrace 
    end
    
    
    def check_values( field, zotero_value ="", solr_value=[])
        zotero_value.is_a?(String) ? zotero_value = [zotero_value] : zotero_value ||= []
        solr_value ||= []
        unless zotero_value == solr_value
            raise ArgumentError.new("Mismatch in #{field}. zotero: #{zotero_value} solr: #{s}") 
        end 
    end
    
     def update_record(field, msg)
        unless @zotero_ingest.nil?
           ZoteroIngest.update(@zotero_ingest.id, { field.to_sym => msg  } )
        end
      end
      
  end
end