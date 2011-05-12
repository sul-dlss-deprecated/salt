require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/stanford/salt_document'


describe Stanford::SaltDocument do
  
  describe "it should itialize correctly" do
     
     before(:each) do 
       @mock_salt_doc_repo = mock("Stanford::Repository")
       @mock_salt_doc_repo.stubs(:get_datastream).returns("<xml/>")
     end
     
    it "should raise an error if it have a pid" do
      lambda { Stanford::SaltDocument.new }.should raise_error
    end 
     
     
     it "should have the instance variables properyl set up by default" do
       Stanford::Repository.expects(:new).returns(@mock_salt_doc_repo)
       @salt_doc = Stanford::SaltDocument.new("druid:123")
       @salt_doc.datastreams.should == {"extracted_entities" => "<xml/>", "zotero" => "<xml/>"}
       @salt_doc.solr_document.should == {"id" => ["druid:123"]}
       @salt_doc.repository.should == @mock_salt_doc_repo
       @salt_doc.pid.should == "druid:123"
     end
     
     it "should be allow for defaults to be overridden" do
         
         @mock_salt_doc_repo2 = mock("Stanford::Repository2")
         @mock_salt_doc_repo2.stubs(:get_datastream).returns("<xml/>")
                 
         @salt_doc = Stanford::SaltDocument.new("druid:456", {:repository=> @mock_salt_doc_repo2, :datastreams => ["foo", "bar"] })
         
         @salt_doc.datastreams.should == {"foo" => "<xml/>", "bar" => "<xml/>"}
         @salt_doc.datastreams.should_not == {"extracted_entities" => "<xml/>", "zotero" => "<xml/>"}
         @salt_doc.solr_document.should == {"id" => ["druid:456"]}
         @salt_doc.repository.should == @mock_salt_doc_repo2
         @salt_doc.repository.should_not == @mock_salt_doc_repo
         @salt_doc.pid.should == "druid:456"
             
     end
    
  end
  
  
  describe "#to_solr" do 
    before(:each) do 
       @mock_salt_doc_repo = mock("Stanford::Repository")
       # adding all the namespaces that it expects with the Zotero XML 
       @mock_salt_doc_repo.stubs(:get_datastream).returns('<rdf:RDF xmlns:bib="http://purl.org/net/biblio#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:link="http://purl.org/rss/1.0/modules/link/" xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:vcard="http://nwalsh.com/rdf/vCard#" xmlns:z="http://www.zotero.org/namespaces/export#"/>')
       Stanford::Repository.expects(:new).returns(@mock_salt_doc_repo)
    end
    
    
    it "should return a hash and store it in @solr_document" do
      salt_doc = Stanford::SaltDocument.new("druid:123")
      solr_doc = salt_doc.to_solr
      solr_doc.should == {"id" => ["druid:123"]}
      solr_doc.should == salt_doc.solr_document
    end
      
    it "should run the _to_solr methods for all datastreams in the @datastreams" do
      salt_doc = Stanford::SaltDocument.new("druid:123")
          
      salt_doc.expects(:extracted_entities_to_solr).once
      salt_doc.expects(:zotero_to_solr).once
      salt_doc.to_solr
    end
    
    it "should raise not run an default methods if the datastream does not have a matching method when using #to_solr" do
      salt_doc = Stanford::SaltDocument.new("druid:123", {:datastreams => ["foo"]})
      salt_doc.expects(:extracted_entities_to_solr).never
      salt_doc.expects(:zotero_to_solr).never
      
      salt_doc.to_solr  
    end
    
  end
  
  describe "#*_to_solr" do
    before(:each) do 
       @mock_salt_doc_repo = mock("Stanford::Repository")
       @mock_salt_doc_repo.stubs(:get_datastream).with("druid:123", "extracted_entities").returns(fixture("extracted_entities_ds.xml"))
       @mock_salt_doc_repo.stubs(:get_datastream).with("druid:123", "zotero").returns(fixture("zotero_ds.xml"))
       
       Stanford::Repository.expects(:new).returns(@mock_salt_doc_repo)
       @salt_doc = Stanford::SaltDocument.new("druid:123")
        @salt_doc.solr_document.should == {"id" => ["druid:123"] }
    end
    
    it "#extracted_entities_to_solr should update the @solr_document hash with proper values mapped from the extracted_entities datastream" do
      @salt_doc.extracted_entities_to_solr
      @salt_doc.solr_document.should == {"id" => ["druid:123"], "company_facet"=>["KNOWLEDGE SYSTEMS LABORATORY", "Bayesian Belief Networks", "MITRE Corp", "E.I. DuPont de Nemours & Company"], "provinceorstate_facet"=>["California", "Delaware"], "city_facet"=>["Wilmington"], "person_facet"=>["EDWARD FEIGENBAUM", "Paul Morawski", "Ed", "Palo Alto"]}
    end
    
    it "#zotero_to_solr should update the @solr_document hash with proper values mapped from the datastream" do
      @salt_doc.zotero_to_solr
      @salt_doc.solr_document.should ==   {"month_s"=>["03"], "box_s"=>["36"], "subseries_s"=>["HPP Papers, Various Authors (1 of 2)1970 -\n      1979"], "year_facet"=>["1977"], "organization_facet"=>["Stanford Heuristic Programming Project"], "year_sort"=>["1977"], "subseries_facet"=>["HPP Papers, Various Authors (1 of 2)1970 -\n      1979"], "title_s"=>["A Model for Learning Systems"], "box_facet"=>["36"], "date_s"=>["1977-03"], "month_facet"=>["03"], "folder_sort"=>["15"], "folder_s"=>["15"], "itemType_s"=>["report"], "donor_tags__facet"=>["InProgress", "Machine Learning"], "donor_tags__s"=>["InProgress", "Machine Learning"], "id"=>["druid:123"], "year_s"=>["1977"], "itemType_facet"=>["report"], "box_sort"=>["36"], "subseries_sort"=>["HPP Papers, Various Authors (1 of 2)1970 -\n      1979"], "itemType_display"=>["report"], "title_display"=>["A Model for Learning Systems"], "month_sort"=>["03"], "identifiers_s"=>["00009059"], "folder_facet"=>["15"]}
      
    end
    
  end
  
  
  
end
  
  