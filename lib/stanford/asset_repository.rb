module Stanford
  class AssetRepository
    
   
  #
  # This method initializes the asset repository
    attr_reader :base
    attr_reader :username
    attr_reader :password



   def initialize(base=nil, username=nil, password=nil)

      if base.nil? or username.nil? or password.nil?
        base = ASSET_SERVER_URI
        username = ASSET_SERVER_USER
        password = ASSET_SERVER_PASSWORD
      end

      #puts "Initializing Repository at #{base}" 
      base.chop! if /\/$/.match(base)
      @base = base
      @username = username
      @password = password
    end

     #       
     # This method gets the thumbnail for the asset form the asset repository. Thumbnails are named {druid}/thumb.jpg
    def get_thumbnail( druid )
      uri = URI.parse(@base + "/" + druid + "/thumb.jpg"  )  
      return Stanford::AssetRepository.http(uri) 
    rescue
     return nil       
    end

    # this method gets a PDF from the asset repository. PDF's are named {druid}/{druid}.pdf
    def get_pdf( druid )
      uri = URI.parse("#{@base}/#{druid}/#{druid}.pdf")
      return Stanford::AssetRepository.http(uri) 
    rescue  
      return nil
    end
    
    def get_json( druid )
       uri = URI.parse("#{@base}/#{druid}/flipbook.json")
       return Stanford::AssetRepository.http(uri) 
    end
    
    # gets a page jp2000 from the asset repo. JP2000s are named {druid}/{druid}_{page number}.jp2. Page numbers are 5 digit format (00004). 
    def get_page_jp2(druid, page_number)
      uri = URI.parse(@base + "/" + druid + "/#{druid}_#{page_number}.jp2")
      return Stanford::AssetRepository.http(uri) 
    rescue
         return nil
    end
    
    # gets a page Alto XML from the asset repo. XML files are named {druid}/{druid}_{page number}.xml. Page numbers are 5 digit format (00004). 
    def get_page_xml(druid, page_number)
       uri = URI.parse(@base + "/" + druid + "/#{druid}_#{page_number}.xml"  )    
      return Stanford::AssetRepository.http(uri) 
    rescue
       return nil
    end

private

     def self.http(uri, limit = 10)
       request = Net::HTTP::Get.new(uri.request_uri) 
       request.basic_auth @username, @password
       response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
       case response
       when Net::HTTPSuccess then response.body
       when Net::HTTPRedirection then Stanford::AssetRepository.http(response['location'], limit - 1)
       else
         raise response.error!
       end
       rescue Exception => e
             raise e
     end #rescue 
    
    
    
  end
end