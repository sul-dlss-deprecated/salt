require_dependency  'lib/stanford/asset_repository'
require_dependency 'blacklight/catalog'
require 'rest_client'

class Asset
  
  attr_accessor :druid
  attr_accessor :page_number
  attr_accessor :asset_repository_connection
  
  def initialize(id, page_number = nil)
    @druid = id    
    @page_number = page_number
    @asset_repository_connection = Stanford::AssetRepository.new
  end
  
  def get_pdf
    @asset_repository_connection.get_pdf(@druid)
  end
  
  def get_thumbnail
    @asset_repository_connection.get_thumbnail(@druid)
  end
  
  def get_page_xml
    unless @page_number.nil?
      @asset_repository_connection.get_page_xml(@druid, @page_number)
    end
  end
  
  def get_page_jp2
    unless @page_number.nil?
     @asset_repository_connection.get_page_jp2(@druid, @page_number) 
    end
  end
  
  def get_json
    @asset_repository_connection.get_json(@druid)
  end
  
  def get_flipbook
      @druid.include?("druid:") ? id = @druid : id = "druid:#{@druid}"
      RestClient.get("#{FLIPBOOK_URL}/embed.jsp?id=#{id}").body
  end
  
  def self.get_flipbook_asset(file, mime)
    file.include?(mime) ? file.chomp!(mime) : file = file
    if mime == ".css"
      uri = "#{FLIPBOOK_URL}/css/#{file}#{mime}"
    elsif mime == ".js"
      uri = "#{FLIPBOOK_URL}/js/#{file}#{mime}"
    elsif mime == ".png"
      uri = "#{FLIPBOOK_URL}/images/#{file}#{mime}"
    end
    return RestClient.get(uri).body
  end
  


end