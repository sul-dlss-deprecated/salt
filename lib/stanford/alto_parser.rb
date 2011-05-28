require 'rubygems'
require 'nokogiri'

module Stanford
<<<<<<< HEAD
  class AltoParser < Nokogiri::XML::SAX::Document
=======
  class AtloParser < Nokogiri::XML::SAX::Document
>>>>>>> fb9562ede65236814b656f40aee5b23dbbc3dcb5
    
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