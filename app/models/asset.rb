require_dependency  'lib/stanford/asset_repository'
require_dependency 'blacklight/catalog'

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
  
private


end