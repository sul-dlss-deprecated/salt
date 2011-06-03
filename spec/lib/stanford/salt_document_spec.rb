require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
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
     
     it "should assign the asset_repo correctly if passed in on new" do
       @salt_doc = Stanford::SaltDocument.new("druid:123", {:asset_repo => "http://fakesite.com" })
       @salt_doc.asset_repo.should == "http://fakesite.com"
     end
     
     it "should assign the warnings correctly if passed in on new" do
       @salt_doc = Stanford::SaltDocument.new("druid:123", { :warnings => true } )
       @salt_doc.warnings.should be_true
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
      solr_doc["id"].should ==  ["druid:123"]
      solr_doc.should ==   {"access_display"=>["Private"], "identifiers_t"=>["druid:123"], "series_s"=>["Accession 2005-101"], "series_t"=>["Accession 2005-101"], "text"=>[], "series_display"=>["Accession 2005-101"], "id"=>["druid:123"], "access_facet"=>["Private"], "series_facet"=>["Accession 2005-101"], "series_sort"=>["Accession 2005-101"], "identifiers_s"=>["druid:123"]}
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
  
  describe "fulltext_to_solr" do
    before(:all) do 
       @mock_salt_doc_asset_repo = mock("Stanford::AssetRepository")
       @mock_salt_doc_asset_repo.stubs(:get_json).returns({ "pages" => [ "a page" ]})
       @mock_salt_doc_asset_repo.stubs(:get_page_xml).returns("<xml><String CONTENT='this'/><String CONTENT='is'/><String CONTENT='alto'/><word CONTENT='not.'/></xml>")
    end
   
    it  "should get the full text index from the alto files" do 
       @salt_doc = Stanford::SaltDocument.new("druid:456", {:asset_repo=> @mock_salt_doc_asset_repo })           
       @salt_doc.fulltext_to_solr
       @salt_doc.solr_document["text"].should == ["this is alto"]
    end  
    
  end
  
  describe "#get_alto" do
    
    it "should get the alto file for a page" do
       @mock_salt_doc_asset_repo = mock("Stanford::AssetRepository")
       @mock_salt_doc_asset_repo.stubs(:get_json).returns({ "pages" => [ "a page" ]})
       xml = "<xml><String CONTENT='this'/><String CONTENT='is'/><String CONTENT='alto'/><word CONTENT='not.'/></xml>"
       @mock_salt_doc_asset_repo.stubs(:get_page_xml).returns(xml)
      
       @salt_doc = Stanford::SaltDocument.new("druid:456", {:asset_repo=> @mock_salt_doc_asset_repo })  
       @salt_doc.get_alto("1").should == xml
    end
    
    it "should return nil if there's an error" do
         @salt_doc = Stanford::SaltDocument.new("druid:456")
         @salt_doc.get_alto("1").should be_nil
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
      @salt_doc.solr_document.should == {"company_facet"=>["KNOWLEDGE SYSTEMS LABORATORY", "Bayesian Belief Networks", "MITRE Corp", "E.I. DuPont de Nemours & Company"], "provinceorstate_facet"=>["California", "Delaware"], "organization_facet"=>["Mechanical Engineering Faculty"], "city_facet"=>["Wilmington"], "id"=>["druid:123"], "person_facet"=>["EDWARD FEIGENBAUM", "Paul Morawski", "Ed", "Palo Alto"]}
    end
    
    it "#zotero_to_solr should update the @solr_document hash with proper values mapped from the datastream" do
      @salt_doc.zotero_to_solr
      @salt_doc.solr_document.should ==  {"person_s"=>["Bruce Buchanan", "Reid Smith", "Tom Mitchell", "R. Shestek"], "access_display"=>["Private"], "identifiers_t"=>["druid:123", "00009059"], "series_s"=>["Accession 2005-101"], "month_s"=>["03"], "year_display"=>["1977"], "box_s"=>["36"], "subseries_s"=>["HPP Papers, Various Authors (1 of 2)1970 -\n      1979"], "person_t"=>["Bruce Buchanan", "Reid Smith", "Tom Mitchell", "R. Shestek"], "organization_t"=>["Stanford Heuristic Programming Project"], "donor_tags_facet"=>["InProgress", "Machine Learning"], "series_t"=>["Accession 2005-101"], "month_t"=>["03"], "year_facet"=>["1977"], "subseries_t"=>["HPP Papers, Various Authors (1 of 2)1970 -\n      1979"], "organization_facet"=>["Stanford Heuristic Programming Project"], "year_sort"=>["1977"], "box_t"=>["36"], "subseries_facet"=>["HPP Papers, Various Authors (1 of 2)1970 -\n      1979"], "title_s"=>["A Model for Learning Systems"], "box_facet"=>["36"], "title_t"=>["A Model for Learning Systems"], "series_display"=>["Accession 2005-101"], "month_facet"=>["03"], "date_s"=>["1977-03"], "folder_s"=>["15"], "folder_sort"=>["15"], "itemType_s"=>["report"], "month_display"=>["03"], "date_t"=>["1977-03"], "box_display"=>["36"], "folder_t"=>["15"], "id"=>["druid:123"], "itemType_t"=>["report"], "person_facet"=>["Bruce Buchanan", "Reid Smith", "Tom Mitchell", "R. Shestek"], "access_facet"=>["Private"], "donor_tags_s"=>["InProgress", "Machine Learning"], "series_facet"=>["Accession 2005-101"], "date_sort"=>["1977-03"], "year_s"=>["1977"], "subseries_display"=>["HPP Papers, Various Authors (1 of 2)1970 -\n      1979"], "folder_display"=>["15"], "itemType_facet"=>["report"], "title_sort"=>["AModelforLearningSystems"], "donor_tags_t"=>["InProgress", "Machine Learning"], "year_t"=>["1977"], "box_sort"=>["36"], "series_sort"=>["Accession 2005-101"], "subseries_sort"=>["HPPPapersVariousAuthors1of219701979"], "itemType_display"=>["report"], "title_display"=>["A Model for Learning Systems"], "month_sort"=>["03"], "identifiers_s"=>["druid:123", "00009059"], "date_facet"=>["1977-03"], "date_display"=>["1977-03"], "folder_facet"=>["15"]}
    end
  end
  
  
  
end
  
  