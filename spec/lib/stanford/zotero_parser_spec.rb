require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'lib/stanford/zotero_parser'
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
        @zp = Stanford::ZoteroParser.new(fixture("zotero_export.xml").path)
    end
    
    it "should run the process_node and update_fedora methods for each node" do
      # fixture document has 20 documents with some memos, so it should run for each document
      @zp.expects(:process_node).times(20).returns(Nokogiri::XML("<foo/>"))
      # update fedora with the last node. 
      @zp.expects(:update_fedora).once
      @zp.process_document
    end
  end
  
  
  describe "#process_node" do
    before(:each) do 
        @zp = Stanford::ZoteroParser.new(fixture("zotero_export.xml").path)
    end
  
    it "should add the memo to the previous document" do
      documentXML = Nokogiri::XML("<rdf><Manuscript/></rdf>")
      memoXML = Nokogiri::XML("<Memo/>").root
      @zp.process_node(memoXML, documentXML).to_xml.should == Nokogiri::XML("<rdf><Manuscript/><Memo/></rdf>").to_xml
    end
    
    it "should build out the XML properly" do
      xml =  Nokogiri::XML(' <rdf:RDF
          xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
          xmlns:dc="http://purl.org/dc/elements/1.1/"
          xmlns:dcterms="http://purl.org/dc/terms/"
          xmlns:bib="http://purl.org/net/biblio#"
          xmlns:z="http://www.zotero.org/namespaces/export#"
          xmlns:link="http://purl.org/rss/1.0/modules/link/"
          xmlns:foaf="http://xmlns.com/foaf/0.1/"
          xmlns:vcard="http://nwalsh.com/rdf/vCard#"
          xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/"><bib:Manuscript rdf:about="fricking namespaces suck">Blah Blah Blah</bib:Manuscript><bib:Manuscript rdf:about="Seriousyly">burp</bib:Manuscript></rdf:RDF>')
      
      expected_xml =     Nokogiri::XML(' <rdf:RDF
              xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
              xmlns:dc="http://purl.org/dc/elements/1.1/"
              xmlns:dcterms="http://purl.org/dc/terms/"
              xmlns:bib="http://purl.org/net/biblio#"
              xmlns:z="http://www.zotero.org/namespaces/export#"
              xmlns:link="http://purl.org/rss/1.0/modules/link/"
              xmlns:foaf="http://xmlns.com/foaf/0.1/"
              xmlns:vcard="http://nwalsh.com/rdf/vCard#"
              xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/"><bib:Manuscript rdf:about="fricking namespaces suck">Blah Blah Blah</bib:Manuscript></rdf:RDF>')
      
      
      previous = Nokogiri::XML("<xml>Nothing to see here. I'm just being added to fedora and not updated</xml>")
      
      
      
     @zp.expects(:update_fedora).with(previous).once  
     EquivalentXml.equivalent?(@zp.process_node( xml.root.children.first, previous), expected_xml).should be_true      
      
      
    end
    
    
    it "should properly add memo nodes to the previous document node" do
       pending("For some reason this is not working on the hudson server. Nokogiri/LibXML differences...boo.")
       previous = Nokogiri::XML(' <rdf:RDF
          xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
          xmlns:dc="http://purl.org/dc/elements/1.1/"
          xmlns:dcterms="http://purl.org/dc/terms/"
          xmlns:bib="http://purl.org/net/biblio#"
          xmlns:z="http://www.zotero.org/namespaces/export#"
          xmlns:link="http://purl.org/rss/1.0/modules/link/"
          xmlns:foaf="http://xmlns.com/foaf/0.1/"
          xmlns:vcard="http://nwalsh.com/rdf/vCard#"
          xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/"><bib:Manuscript rdf:about="fricking namespaces suck">Blah Blah Blah</bib:Manuscript></rdf:RDF>')
       
       memo = Nokogiri::XML(' <rdf:RDF
              xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
              xmlns:dc="http://purl.org/dc/elements/1.1/"
              xmlns:dcterms="http://purl.org/dc/terms/"
              xmlns:bib="http://purl.org/net/biblio#"
              xmlns:z="http://www.zotero.org/namespaces/export#"
              xmlns:link="http://purl.org/rss/1.0/modules/link/"
              xmlns:foaf="http://xmlns.com/foaf/0.1/"
              xmlns:vcard="http://nwalsh.com/rdf/vCard#"
              xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/"><bib:Memo>This is a note about the previous document</bib:Memo></rdf:RDF>')
       
       zotero_document= previous.dup
       zotero_document.root << memo.root.children.first.dup
       
   
       @zp.expects(:update_fedora).with(previous).never 
       EquivalentXml.equivalent?(@zp.process_node( memo.root.children.first, previous), final).should be_true      
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