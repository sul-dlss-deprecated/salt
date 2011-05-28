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
  
  def get_json
    @asset_repository_connection.get_json(@druid)
  end
  
  def get_flipbook
    @druid.include?("druid:") ? id = @druid : id = "druid:#{@druid}"
    uri = URI.parse("#{FLIPBOOK_URL}/embed.jsp?id=#{id}")
    return Asset.http(uri)
  end
  
  def self.get_flipbook_asset(file, mime)
    file.include?(mime) ? file = File.basename(file,mime) : file = file
    if mime == ".css"
      uri = URI.parse("#{FLIPBOOK_URL}/css/#{file}#{mime}")
    elsif mime == ".js"
      uri = URI.parse("#{FLIPBOOK_URL}/js/#{file}#{mime}")
    elsif mime == ".png"
      uri = URI.parse("#{FLIPBOOK_URL}/images/#{file}#{mime}")
    end
    if uri
      return Asset.http(uri)
    else
      return "Cannot find #{file}#{mime}"
    end
  end
  
  
  
  #  return get(flipbook_url)
  #  iframe = "<iframe src='#{flipbook_url}' width='99%' height='450px'/>"
  #  flipbook_link = "<a href='#{flipbook_url}' style='cursor:pointer;' onclick=\"window.open('#{flipbook_url}','status=0','toolbar=0','location=0','menubar=0','directories=0','navigation=0');return false;\">Open viewer in new window</a>"
  #  return "#{iframe}#{flipbook_link}" 
  # end
  
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