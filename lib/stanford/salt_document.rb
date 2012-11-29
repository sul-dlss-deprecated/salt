require 'rubygems'
require 'rsolr'
require 'rsolr-ext'
require 'json'
require 'yaml'

module Stanford
  
  class SaltDocument
    
    
    attr_accessor :solr_document
    attr_accessor :repository
    attr_accessor :asset_repo
    attr_accessor :datastreams
    attr_accessor :pid
    attr_accessor :term_authority
    
    def initialize(pid, options = {})
      if !pid.is_a?(String) || pid.empty?
        raise ArgumentError.new("Must have a PID for the salt document")
      end
      
  
      # this is Yaml file produced by Google Refine to match values to a common authority term. 
      if File.exists?(File.join(Rails.root, "lib/stanford/term_authority.yaml"))
        @term_authority = YAML::load_file(File.join(Rails.root, "lib/stanford/term_authority.yaml"))
      else
        @term_authority = {}
      end
      
      @pid = pid
      @solr_document ||= {"id" => [@pid]}
      
      
      if options[:repository].nil? 
         @repository = Stanford::Repository.new()
      else
         @repository = options[:repository]
      end
      
      if options[:asset_repo].nil? 
         @asset_repo = Stanford::AssetRepository.new()
      else
         @asset_repo = options[:asset_repo]
      end
      
      @datastreams = {}
      if options[:datastreams].nil? or options[:datastreams] == :default
         get_datastreams(@pid,["extracted_entities", "zotero"])
      else
         get_datastreams(@pid, options[:datastreams])
      end
        
    end
    
    #this method returns a hash that will be indexed in solr. 
    def to_solr
     
      @datastreams.each do |key, value|
        if self.methods.include?("#{key}_to_solr")
          self.send("#{key}_to_solr")
        end #if
      end
      
      fulltext_to_solr
      
      return @solr_document
    end
    
    # this method updates the solr document with values from the OCR text. 
    #
    def fulltext_to_solr
      @solr_document["text"] ||= []
      json = get_json
      
      unless json.nil?
        i = 1
        json["pages"].each do |p|
         
          xml = get_alto(i.to_s)
          unless xml.nil?
             alto = Stanford::AltoParser.new
             parser = Nokogiri::XML::SAX::Parser.new(alto)
             parser.parse(xml)
             @solr_document["text"] << alto.text.strip
             i += 1
          end
        end
      end
    end
    
    #this method gets the json from the asset repository
    def get_json
      return JSON(@asset_repo.get_json(@pid.gsub("druid:", "")))
    rescue => e
      return nil
    end
    
    #this method takes a page string and returns the alto XML.
    def get_alto(page)
      return @asset_repo.get_page_xml(@pid.gsub("druid:", ""), page.rjust(5, "0"))
    rescue => e
      return nil
    end
    
    
    # this method takes the @datastream["extracted_entities"], processes it, merges it with the @solr_document and returns @solr_document. 
    # extracted entities are only applied as facets. facet values we want from this ds: technology, company, person, organization, city, state  
    def extracted_entities_to_solr()
        ee_hash = {}
        xml  = Nokogiri::XML(@datastreams["extracted_entities"])  
        xml.search("//facet").each do |facet|
          ee_hash["#{facet['type']}_facet"] ||= []
          ee_hash["#{facet['type']}_facet"] = ee_hash["#{facet['type']}_facet"] + authorize_term("#{facet['type']}_facet", facet.content)
        end
        update_solr_document(ee_hash)
         
        return @solr_document
        
    end
    
    
    def zotero_to_solr
    
      
      zotero_hash = generate_zotero_defaults
      json = generate_hash
      
      
      ["title_s", "title_display", "title_t"].each { |k| zotero_hash[k] ||= []; zotero_hash[k] << json["title"] } 
      ["originator_facet", "originator_s", "originator_t"].each {|p|  zotero_hash[p] = []; json["originator"].collect { |o| zotero_hash[p] = zotero_hash[p] + authorize_term(p, o); } }
      
      format_date(json["date"]).each do |key,vals|
        ["facet", "sort", "s", "display", "t"].each {|v| zotero_hash["#{key}_#{v}"] ||= [];  zotero_hash["#{key}_#{v}"] << vals }
      end 
      ["documentType_facet", "documentType_s", "documentType_display", "documentType_t"].each {|i|  zotero_hash[i] ||= []; zotero_hash[i] << json["document_type"]  }
      ["documentSubType_facet", "documentSubType_s", "documentSubType_display", "documentSubType_t"].each {|i|  zotero_hash[i] ||= []; zotero_hash[i] << json["document_subtype"]  }
      ["containingWork_facet", "containingWork_s", "containingWork_display", "containingWork_t"].each {|c| zotero_hash[c] ||= []; zotero_hash[c] << json["containing_work"]}
      ["corporateEntity_facet", "corporateEntity_t"].each { |c| zotero_hash[c] ||= []; zotero_hash[c] << json["corporate_entity"]}
      ["extent_s", "extent_t", "extent_display"].each {|e| zotero_hash[e] ||= []; zotero_hash[e] << json["extent"]}
      ["language_facet", "language_s", "language_display", "language_t"].each {|l| zotero_hash[l] ||= []; zotero_hash[l] << json["language"]}
      ["abstract_s", "abstract_t", "abstract_display"].each {|a| zotero_hash[a] ||= []; zotero_hash[a] << json["abstract"]}
      ["EAFHardDriveFileName_display", "EAFHardDriveFileName_t", "EAFHardDriveFileName_s"].each {|f| zotero_hash[f] ||= []; zotero_hash[f] << json["EAF_hard_drive_file_name"]} 
      ["box_facet", "box_t", "box_s", "box_t", "box_display"].each {|b| zotero_hash[b] ||= []; zotero_hash[b] << json["box"].first}
      ["folder_facet", "folder_t", "folder_s", "folder_t", "folder_display"].each {|f| zotero_hash[f] ||= []; zotero_hash[f] << json["folder"].first}
      ["subseries_facet", "subseries_t", "subseries_s", "subseries_t", "subseries_display"].each {|s| zotero_hash[s] ||= []; zotero_hash[s] << json["subseries"].first}
             
     
      
      json["tags"].each do |tag|
        if tag.upcase == "PUBLIC"
          zotero_hash["public_b"] = ['true'] 
          zotero_hash["access_display"] = ["Public"]
          zotero_hash["access_facet"] = ["Public"]
        elsif tag.upcase == 'PRIVATE'
          zotero_hash["public_b"] = ['false'] 
          zotero_hash["access_display"] = ["Private"]
          zotero_hash["access_facet"] = ["Private"]
        else
          ["facet", "s", "t"].each {|v| zotero_hash["donor_tags_#{v}"] ||= [];  zotero_hash["donor_tags_#{v}"] << tag.strip }
        end
      end
      
      unless json["notes"].nil?
        json["notes"].each do |note|
          ["s", "t", "display"].each {|n| zotero_hash["notes_#{n}"] ||= []; zotero_hash["notes_#{n}"] << note }
        end
      end
      
      update_solr_document(zotero_hash)      
      return @solr_document
    end
    
# private
    
    # This builds @datastreams as a hash with keys as ds labels and string values as the XML content
    def get_datastreams(pid, datastreams=[]) 
        datastreams.each do |ds|
          @datastreams[ds] = @repository.get_datastream(pid, ds)
        end
    end
    
    # this reduces and duplicates and updates the @solr_document. 
    def update_solr_document(new_hash={})
      @solr_document.merge!(new_hash) {|key, oldval, newval| oldval + newval }
      @solr_document.each_value {|v| v.uniq! }
    end
   
    # takes a string and returns a hash with { year => 1992, month => 12, day => 01, date=> 1992-12-01 }
    def format_date(date_string)
        date_hash = {}
        year, month, day = date_string.split("-").map {|x| x.to_i}
        
        date = ""
        if !year.nil? && year.to_s.length == 4
          date_hash["year"] = year.to_s
          date << date_hash["year"]
        end
        
        if !month.nil? && 0 < month && month < 13
          date_hash["month"] =  month.to_s.rjust(2, '0')
          date << "-#{date_hash["month"]}"
        end
        
        if !day.nil? && 0 < day && day < 32   
           date_hash["day"] = day.to_s.rjust(2, '0')
           date << "-#{date_hash["day"]}"
        end
        
        date_hash["date"] = date
        date_hash
    end
    
    
    # take a string from the coverage and returns a formated hash. 
    # coverage string values look like : Box: 36, Folder: 15, Title: HPP Papers, Various Authors (1 of 2)1970 -
    # returns hash { box => 36, folder => 15, subseries => HPP Papers, Various Authors (1 of 2)1970 - }. 
    # title in this case is the section unittitel from the EAD. 
    def format_coverage(coverage_string)
      coverage_string.gsub!("\n", "")
      coverage_hash = { "subseries" => [coverage_string.split("Title:")[1].to_s.strip] }
      parts = coverage_string.split(",")
      coverage_hash["box"] = [parts.shift.gsub("Box:", '').to_s.strip]
      coverage_hash["folder"] =  [parts.shift.gsub("Folder:", '').to_s.strip]
      coverage_hash
    end
    
    
    # this method generates the hash from JSON using the PHP script and ensures key values are present
     def generate_hash
       
       tmp_file = "/tmp/zotero.xml"
       
       File.open(tmp_file, "w") { |f| f << @datastreams["zotero"] }
       
       # Check to make sure zotero.xml file has been written
       raise "Couldn't write #{tmp_file}" unless File.exist?(tmp_file) and File.file?(tmp_file)
       
       php_output = `/usr/bin/env php #{File.join(Rails.root, 'lib/stanford/zotero_to_json.php' )} /tmp/zotero.xml`
       # puts php_output.inspect
       
       json = JSON(php_output)
       # puts json.inspect
       json.is_a?(Array) ? json = json.first : json = json
       
       if json.nil? or json.is_a?(String)
          json = {}
        end

      # this is really stupid, but it's a quick fix to get the coverage data.
      xml = Nokogiri::XML(open("/tmp/zotero.xml"))
      xml.search("//dc:coverage").each do |cov|   
        format_coverage(cov.content.strip).each do |key,vals|
          json["#{key}"] ||= []  
          json["#{key}"] << vals.first
        end
      end
       ["druid", "title", "originator", "date", "document_type", "document_subtype",
          "containing_work", "corporate_entity", "extent", "language", "abstract", 
          "EAF_hard_drive_file_name", "tags", "notes", "box", "folder", "subseries"].each {|k| json[k] ||= "" }
       return json

     end
    
    
    # this method take the Zotero XML datastream and returns the series information for the salt document
    def generate_zotero_defaults
      xml  = Nokogiri::XML(@datastreams["zotero"])      
      id_hash = {}
       # no public or private tag -> private per tcramer, 11/28
      id_hash["access_display"] ||= ["Private"]
      id_hash["access_facet"] ||= ["Private"]
      id_hash["public_b"] ||= ['false'] 
      id_hash["identifiers_s"] ||= [@pid]
      id_hash["identifiers_t"] ||= [@pid]
      
      xml.search("//dcterms:LCC").each do |id| 
            id_hash["identifiers_s"] << id.content.strip
            id_hash["identifiers_t"] << id.content.strip
      end
      
      series = "Accession 2005-101"
      id_hash["identifiers_s"].each do |id|
           if id.include?("SC340_1986") 
             series = "Accession 1986-052"
           end
      end
      
      ["facet", "display", "s", "t", "sort"].each {|v| id_hash["series_#{v}"] ||= [];  id_hash["series_#{v}"] << series }
      return id_hash
    end
    
    # this method is to check values against the authorized_term.yaml file. It take a solr field label (string), a term (string) and returns an array.
    # if the solr field is a _facet or _display field, only the cononical values are returns. If it's a search field, both the dirty and cononical values are returned.
    def authorize_term(field, term)
      authorized_terms = []
      if field.include?("_facet") or field.include?("_display")
          authorized_terms << check_term(field.split("_")[0], term) # the .split is b/c "originator_display" would be under the "originator" values in the yaml file
      else
          authorized_terms << term
          authorized_terms << check_term(field.split("_")[0], term)
      end
      
      return authorized_terms.uniq
  
    end
    
    #convenince method to check auth file
    def check_term(term_type, term)      
        if !@term_authority[term_type]
           authorized_term  = term
        elsif !@term_authority[term_type][term].nil?
           @term_authority[term_type][term] == "REMOVE" ? authorized_term = "" : authorized_term = @term_authority[term_type][term]
        else
           authorized_term  = term
        end
        
       return authorized_term
        
    end
     
  end
end


