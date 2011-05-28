require 'rubygems'
require 'rsolr'
require 'rsolr-ext'
<<<<<<< HEAD
require 'lib/stanford/alto_parser'
=======
require 'alto_parser'
>>>>>>> fb9562ede65236814b656f40aee5b23dbbc3dcb5
require 'lib/stanford/repository'

module Stanford
  
  class SaltDocument
    
    
    attr_accessor :solr_document
    attr_accessor :repository
    attr_accessor :datastreams
    attr_accessor :pid
    attr_accessor :warnings
    
    
    def initialize(pid, options = {})
      if pid.nil?
        raise "Must have a PID for the salt document"
      else
        @pid = pid
        @solr_document ||= {"id" => [@pid]}
        
        
        if options[:repository].nil? 
           @repository = Stanford::Repository.new()
        else
           @repository = options[:repository]
        end
        
        if options[:warnings] == true
          @warnings = true
        end
        
        @datastreams = {}
        if options[:datastreams].nil? or options[:datastreams] == :default
           get_datastreams(@pid,["extracted_entities", "zotero"])
        else
           get_datastreams(@pid, options[:datastreams])
        end
        
      end    
    end
    
    #this method returns a hash that will be indexed in solr. 
    def to_solr
     
      @datastreams.each do |key, value|
        if self.methods.include?("#{key}_to_solr")
          self.send("#{key}_to_solr")
        else
          if @warnings == true
            p "Warning: No #{key}_to_solr method found. Data from #{key} datastream will not be used."
          end
        end #if
      end
      
      fulltext_to_solr
      
      return @solr_document
    end
    
    # this method updates the solr document with values from the OCR text. 
    #
    def fulltext_to_solr
      asset_dir = @pid.gsub("druid:","")
      Dir.glob("/home/lyberadmin/assets/#{asset_dir}/#{asset_dir}_*.xml").each do |file|
        @solr_document["text"] ||= []
        alto = Stanford::AltoParser.new
        parser = Nokogiri::XML::SAX::Parser.new(alto)
        parser.parse(File.read(file))
        @solr_document["text"] << alto.text
      end
      
      
    end
    
    # this method takes the @datastream["extracted_entities"], processes it, merges it with the @solr_document and returns @solr_document. 
    # extracted entities are only applied as facets. facet values we want from this ds: technology, company, person, organization, city, state
    
    def extracted_entities_to_solr()
        ee_hash = {}
        xml  = Nokogiri::XML(@datastreams["extracted_entities"])  
        xml.search("//facet").each do |facet|
          ee_hash["#{facet['type']}_facet"] ||= []
          ee_hash["#{facet['type']}_facet"] << facet.content
        end
        update_solr_document(ee_hash)
        
        
        return @solr_document
        
    end
    
    
    # this method takes the @datastream["zotero"], processes it, merges it with the @solr_document and returns @solr_document. 
    # values we want from this ds: itemType, dc:title, bib:authors, foaf:organizations, dc:subject, dcterms:LCC, dc:date, dc:coverage (which has values pulled from the EAD ), 
    def zotero_to_solr
      zotero_hash = {}
      xml = Nokogiri::XML(@datastreams["zotero"])
      
      xml.search("//z:itemType").each do |node|
        ["itemType_facet", "itemType_s", "itemType_display", "itemType_t"].each {|i| zotero_hash[i] ||= []; zotero_hash[i] << node.content.strip }
      end
      
      xml.search("//dc:title").each do |title|
        ["title_s", "title_display", "title_t"].each {|k| zotero_hash[k] ||= []; zotero_hash[k] << title.content.strip }
        zotero_hash["title_sort"] ||= []
        zotero_hash["title_sort"] << title.content.strip.gsub(/(\W)*/,'') #for the sort we only want alpha-num characters
      end
      
      xml.search("//bib:authors/rdf:Seq/rdf:li/foaf:person").each do |person|
        ["person_facet", "person_s", "person_t"].each {|p| zotero_hash[p] ||= [];  zotero_hash[p] << person.content.strip }
      end
      
      xml.search("//foaf:Organization").each do |org|
        zotero_hash["organization_facet"] ||= []
        zotero_hash["organization_facet"] << org.content.strip
        zotero_hash["organization_t"] ||= []
        zotero_hash["organization_t"] << org.content.strip
      end
      
      # currently, we are using the subjects to mark the public/private status of the document
       zotero_hash["access_display"] ||= ["Private"]
       zotero_hash["access_facet"] ||= ["Private"]
       
      xml.search("//dc:subject[not(dcterms:LCC)]").each do |sub|
        if sub.content.upcase == "PUBLIC"
          zotero_hash["public_b"] = ['true'] 
          zotero_hash["access_display"] = ["Public"]
           zotero_hash["access_facet"] = ["Public"]
        else   
          ["facet", "s", "t"].each {|v| zotero_hash["donor_tags_#{v}"] ||= [];  zotero_hash["donor_tags_#{v}"] << sub.content.strip }
        end
      end
      
      xml.search("//dcterms:LCC").each do |id|
        zotero_hash["identifiers_s"] ||= []
        zotero_hash["identifiers_s"] << id.content.strip
         zotero_hash["identifiers_t"] ||= []
          zotero_hash["identifiers_t"] << id.content.strip
      end
      
      # if the identifier has SC340 present, it's part of the 1986 Accession, otherwise it's part of the 2005 accession. 
      series = "Accession 2005-101"
      zotero_hash["identifiers_s"].each do |id|
         if id.include?("SC340_1986") 
           series = "Accession 1986-052"
         end
      end
      ["facet", "display", "s", "t", "sort"].each {|v| zotero_hash["series_#{v}"] ||= [];  zotero_hash["series_#{v}"] << series }
      
      xml.search("//dc:date").each do |date|
          format_date(date.content.strip).each do |key,vals|
            ["facet", "sort", "s", "display", "t"].each {|v| zotero_hash["#{key}_#{v}"] ||= [];  zotero_hash["#{key}_#{v}"] << vals }
          end
      end
      
      xml.search("//dc:coverage").each do |cov|   
        format_coverage(cov.content.strip).each do |key,vals|
          ["facet",  "s", "display", "t"].each {|v| zotero_hash["#{key}_#{v}"] ||= [];  zotero_hash["#{key}_#{v}"] << vals }
          ["sort"].each {|s| zotero_hash["#{key}_#{s}"] ||= [];  zotero_hash["#{key}_#{s}"] << vals.gsub(/(\W)*/,'')    } 
        end
      end
      
      update_solr_document(zotero_hash)
      return @solr_document
    end
    
    
private
    
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
      coverage_hash = { "subseries" => coverage_string.split("Title:")[1].strip }
      parts = coverage_string.split(",")
      coverage_hash["box"] = parts.shift.gsub("Box:", '').strip
      coverage_hash["folder"] =  parts.shift.gsub("Folder:", '').strip
      coverage_hash
    end
    
     
  end
end


