require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Stanford::AltoParser do
  
  it "should return the text after parsing the XML" do
     alto = Stanford::AltoParser.new
     parser = Nokogiri::XML::SAX::Parser.new(alto)
     parser.parse("<xml><String CONTENT='this'/><String CONTENT='is'/><String CONTENT='alto'/><word CONTENT='not.'/></xml>")
     alto.text.strip.should == "this is alto"
  end
  
  
end