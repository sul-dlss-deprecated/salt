require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'equivalent-xml'

describe Stanford::ZoteroParser do
  
  describe "#new" do
    
    it "should initalize correctly" do
      @zp = Stanford::ZoteroParser.new(fixture("zotero_export.xml"))
      @zp.repository.should be_kind_of(Stanford::Repository)
      @zp.xmlfile.path.should == fixture("zotero_export.xml").path
    end
    
    it "should raise error if a file is not passed" do
      lambda { Stanford::ZoteroParser.new }.should raise_exception
    end
  end
  
  
  describe "#process_document" do
    before(:each) do
        @zi = ZoteroIngest.new
        @zi.save
        @zp = Stanford::ZoteroParser.new(fixture("zotero_export.xml").path, @zi)
    end
    
    it "should run the process_node and update_fedora methods for each node" do
      # fixture document has 20 documents with one memos, so it should run for each document
      @zp.should_receive(:process_node).exactly(19).times.and_return(Nokogiri::XML("<foo/>"))
      # update fedora with the last node. 
      @zp.should_receive(:update_fedora).at_least(:once)
      @zp.process_document
    end
    
  end
  
  
  describe "#process_node" do
    before(:each) do 
        @zp = Stanford::ZoteroParser.new(fixture("zotero_export.xml").path)
    end
    
    it "should construct a document from a node" do
      documentXML = Nokogiri::XML("<Manuscript/>")
      expect(@zp.process_node(documentXML.root).root.name).to eq "RDF"
    end
    
    it "should extract any referenced memos from the document" do
      rdf = %Q{
        <rdf:RDF
          xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
          xmlns:dcterms="http://purl.org/dc/terms/"
          xmlns:bib="http://purl.org/net/biblio#"  
        >
          <bib:Manuscript>
            <dcterms:isReferencedBy rdf:resource="#xyz" />
          </bib:Manuscript>  
          <bib:Memo rdf:about="#xyz">
            
          </bib:Memo>
          <bib:Memo rdf:about="#xyz">
            
          </bib:Memo>
          <bib:Memo rdf:about="#abc">
            
          </bib:Memo>
        </rdf:RDF>
      }
      documentXML = Nokogiri::XML(rdf)
      fragment = @zp.process_node(documentXML.xpath("//bib:Manuscript", "bib" => "http://purl.org/net/biblio#").first)
      expect(fragment.xpath("//bib:Memo", "bib" => "http://purl.org/net/biblio#").length).to eq 2
      
    end
  end
  
  describe "#update_fedora" do
     before(:each) do 
          @zp = Stanford::ZoteroParser.new(fixture("zotero_export.xml").path)
     end
    
     it "should update fedora with the proper values to the data stream" do
       xml = Nokogiri::XML(fixture("singleton_zotero_export.xml"))
       @zp.repository.expects(:update_datastream).with('druid:dn211xc8708', "zotero", xml.to_xml ).once
       @zp.update_fedora(xml) 
     end
  end
  
  
   
  
  
 
  
end
