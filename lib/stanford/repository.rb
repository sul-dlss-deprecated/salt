require 'rubygems'
require 'net/http'
require 'open-uri'
require 'nokogiri'

#
# This was written to give a quick/dirty XML datastream utility for Fedora without using
# Active Fedora, which can be slow to retrieve large objects.
#

module Stanford

  class Repository
  
    #
    # This method initializes the fedora repository and solr instance
    attr_reader :base
    attr_reader :username
    attr_reader :password
  
    def initialize(base=nil, username=nil, password=nil)
    
      if base.nil? or username.nil? or password.nil?
        base = FEDORA_URI
        username = FEDORA_USER
        password = FEDORA_PASSWORD
      end
      
      base.chop! if /\/$/.match(base)
      @base = base
      @username = username
      @password = password
    end

    def initialize_queue
           uri = URI.parse(@base + "/objects?query=pid~druid*&maxResults=50000&format=true&pid=true&title=true&resultFormat=xml")
           xml = Nokogiri::XML(Repository.http(uri))
           xml.remove_namespaces!
           xml.search("//pid").collect {|x| x.content }
        end
=begin
    # This method gets druids for processing from fedora and returns them as an array. It will only return a maximum set of 50,000.  
    def initialize_queue
       uri = URI.parse(@base + "/risearch?type=tuples&lang=itql&format=CSV&query=#{CGI.unescapeHTML("select+%24object+from+<%23ri>+where+%24object+<fedora-model%3AhasModel>+<info%3Afedora%2Ffedora-system%3AFedoraObject-3.0>")}")
       pids = []
       open(uri).each_line do |l| 
         if l.include?("druid:")
           pids << l.gsub("info:fedora/","").chomp.strip
         end
       end
       returns pids 
    end
=end
 
   #
   # This method gets a list of datastream ids for an object from Fedora returns it as an array.
   #
 
    def get_datastreams( pid )
      uri = URI.parse(@base + '/objects/' + pid + '/datastreams?format=xml')
      xml =  Nokogiri::XML(Repository.http(uri))
      xml.remove_namespaces!
      dsids = xml.search('//datastream').collect {|id| id["dsid"] }
      return dsids
    rescue
       return nil       
    end
  
   
    #
    # This method retrieves a comprehensive list of datastreams for the given object
    # It returns either a Nokogiri XML object or a IOString 
    #
  
    def get_datastream( pid, dsID )
        uri = URI.parse(@base + '/objects/' + pid + '/datastreams/' + dsID + '/content') 
        return Repository.http(uri)
    rescue => e
        p e
        return nil     
    end
    
    # this method takes  pid, dsID, payload, and mime strings and updates the coresponding fedora datastream with the 
    # provided XML
    def update_datastream(pid, dsID, data, mime='application/xml' )
          uri = URI.parse(@base + '/objects/' + pid + '/datastreams/' + dsID )
          request = Net::HTTP::Put.new(uri.request_uri)
          request.basic_auth @username, @password
          request.body = data
          request.content_type = mime
          response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
          case response
          when Net::HTTPSuccess 
              return Net::HTTPSuccess
          else
              return response.error!
          end
    rescue Exception => e
              return e
    end
    
  private
  
    def Repository.http(uri)
      request = Net::HTTP::Get.new(uri.request_uri) 
      request.basic_auth @username, @password
      
      response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
      case response
      when Net::HTTPSuccess 
          return response.body
      else
          raise response.error!
      end
      rescue Exception => e
          raise e
    end #rescue

  end

end