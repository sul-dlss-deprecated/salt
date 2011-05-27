require 'rubygems'
require 'nokogiri'

module Stanford
  class AltoParser < Nokogiri::XML::SAX::Document
    
    attr_accessor :text
    
    def initialize
      @text = ""
      super
    end
    
    def start_element(element, attributes)
       if element == 'String'
          attributes.each {|a| a[0] == "CONTENT" ? @text << "#{a[1]} " :  "" }
       end
     end
    
    
  end
end


#  require 'tei_document'
#  parser = Nokogiri::XML::SAX::Parser.new(Stanford::TeiDocument.new)
#  parser.parse_file(File.join("/tmp", "zz952vc0091_00079.xml"))