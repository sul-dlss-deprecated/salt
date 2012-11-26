require 'rest_client'

module Stanford
  class AssetRepository

   attr_reader :base

   def initialize(base=nil)

     base = ASSET_SERVER_URI if base.nil?

     base.chop! if /\/$/.match(base)
     @base = base
    end

     #
     # This method gets the thumbnail for the asset form the asset repository. Thumbnails are named {druid}/thumb.jpg
    def get_thumbnail( druid )
      uri = @base + "/" + druid + "/thumb.jpg"
      RestClient.get(uri).body rescue nil
    end

    # this method gets a PDF from the asset repository. PDF's are named {druid}/{druid}.pdf
    def get_pdf( druid )
      uri = "#{@base}/#{druid}/#{druid}.pdf"
      RestClient.get(uri).body rescue nil
    end

    def get_json( druid )
      uri = "#{@base}/#{druid}/flipbook.json"
      RestClient.get(uri).body rescue nil
    end

    # gets a page jp2000 from the asset repo. JP2000s are named {druid}/{druid}_{page number}.jp2. Page numbers are 5 digit format (00004).
    def get_page_jp2(druid, page_number)
      uri = @base + "/" + druid + "/#{druid}_#{page_number}.jp2"
      RestClient.get(uri).body rescue nil
    end

    # gets a page Alto XML from the asset repo. XML files are named {druid}/{druid}_{page number}.xml. Page numbers are 5 digit format (00004).
    def get_page_xml(druid, page_number)
      uri = @base + "/" + druid + "/#{druid}_#{page_number}.xml"
      RestClient.get(uri).body rescue nil
    end
  end
end