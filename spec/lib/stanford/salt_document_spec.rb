require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'lib/stanford/salt_document'


describe Stanford::SaltDocument do
  
  describe "it should itialize correctly" do
     
     before(:each) do 
       @mock_salt_doc_repo = mock("Stanford::Repository")
       @mock_salt_doc_repo.stubs(:get_datastream).returns("<xml/>")
     end
     
    it "should raise an error if it have a pid" do
      lambda { Stanford::SaltDocument.new("") }.should raise_error(ArgumentError, "Must have a PID for the salt document")
      lambda { Stanford::SaltDocument.new() }.should raise_error(ArgumentError, "wrong number of arguments (0 for 1)")
      lambda { Stanford::SaltDocument.new([]) }.should raise_error(ArgumentError, "Must have a PID for the salt document")
    end 
     
     it "should assign the asset_repo correctly if passed in on new" do
       @salt_doc = Stanford::SaltDocument.new("druid:123", {:asset_repo => "http://fakesite.com" })
       @salt_doc.asset_repo.should == "http://fakesite.com"
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
       File.open("/tmp/zotero.xml", "w") { |f| f << '<rdf:RDF xmlns:bib="http://purl.org/net/biblio#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:link="http://purl.org/rss/1.0/modules/link/" xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:vcard="http://nwalsh.com/rdf/vCard#" xmlns:z="http://www.zotero.org/namespaces/export#"/>' }
       @mock_salt_doc_repo = mock("Stanford::Repository")
       # adding all the namespaces that it expects with the Zotero XML 
       @mock_salt_doc_repo.stubs(:get_datastream).returns('<rdf:RDF xmlns:bib="http://purl.org/net/biblio#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:link="http://purl.org/rss/1.0/modules/link/" xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:vcard="http://nwalsh.com/rdf/vCard#" xmlns:z="http://www.zotero.org/namespaces/export#"/>')
       Stanford::Repository.expects(:new).returns(@mock_salt_doc_repo)
    end
    
    
    it "should return a hash and store it in @solr_document" do
      salt_doc = Stanford::SaltDocument.new("druid:123")
      salt_doc.to_solr
      solr_doc = salt_doc.solr_document
      solr_doc["id"].should ==  ["druid:123"]
      solr_doc.should ==    {"access_display"=>["Private"], "identifiers_t"=>["druid:123"], "series_s"=>["Accession 2005-101"], "containingWork_t"=>[""], "abstract_s"=>[""], "box_s"=>[""], "subseries_s"=>[""], "series_t"=>["Accession 2005-101"], "documentSubType_facet"=>[""], "extent_s"=>[""], "abstract_t"=>[""], "subseries_t"=>[""], "corporateEntity_facet"=>[""], "extent_t"=>[""], "EAFHardDriveFileName_display"=>[""], "box_t"=>[""], "subseries_facet"=>[""], "title_s"=>[""], "documentSubType_s"=>[""], "box_facet"=>[""], "text"=>[], "series_display"=>["Accession 2005-101"], "title_t"=>[""], "date_s"=>[""], "documentType_facet"=>[""], "documentSubType_t"=>[""], "containingWork_display"=>[""], "extent_display"=>[""], "folder_s"=>[""], "date_t"=>[""], "containingWork_facet"=>[""], "language_s"=>[""], "EAFHardDriveFileName_s"=>[""], "box_display"=>[""], "folder_t"=>[""], "id"=>["druid:123"], "access_facet"=>["Private"], "series_facet"=>["Accession 2005-101"], "date_sort"=>[""], "documentType_display"=>[""], "documentSubType_display"=>[""], "language_t"=>[""], "EAFHardDriveFileName_t"=>[""], "folder_display"=>[""], "subseries_display"=>[""], "originator_s"=>[], "language_display"=>[""], "series_sort"=>["Accession 2005-101"], "originator_t"=>[], "title_display"=>[""], "originator_facet"=>[], "documentType_s"=>[""], "corporateEntity_t"=>[""], "language_facet"=>[""], "abstract_display"=>[""], "identifiers_s"=>["druid:123"], "date_facet"=>[""], "date_display"=>[""], "documentType_t"=>[""], "containingWork_s"=>[""], "folder_facet"=>[""]}
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
      # @mock_salt_doc_asset_repo.stubs(:get_json).returns({ "pages" => [ "a page" ]})
       xml = "<xml><String CONTENT='this'/><String CONTENT='is'/><String CONTENT='alto'/><word CONTENT='not.'/></xml>"
       @mock_salt_doc_asset_repo.stubs(:get_page_xml).returns(xml)
      
       @salt_doc = Stanford::SaltDocument.new("druid:456", {:asset_repo=> @mock_salt_doc_asset_repo })  
       @salt_doc.get_alto("1").should == xml
    end
    
    it "should return nil if there's an exception raised" do
       @mock_salt_doc_asset_repo = mock("Stanford::AssetRepository")
       @mock_salt_doc_asset_repo.stubs(:get_page_xml).raises(StandardError.new("meatball problems."))
      
       @salt_doc = Stanford::SaltDocument.new("druid:456", {:asset_repo=> @mock_salt_doc_asset_repo })  
       @salt_doc.get_alto("1").should be_nil
    end
    
    it "should return nil if there's an error" do
         @salt_doc = Stanford::SaltDocument.new("druid:456")
         @salt_doc.get_alto("1").should be_nil
    end
    
  end
  
  describe "#*_to_solr" do
    before(:each) do 
       @mock_salt_doc_repo = mock("Stanford::Repository")
       @mock_salt_doc_repo.stubs(:get_datastream).with("druid:123", "extracted_entities").returns(IO.read(fixture("extracted_entities_ds.xml").path))
       @mock_salt_doc_repo.stubs(:get_datastream).with("druid:123", "zotero").returns(IO.read(fixture("zotero_ds.xml").path))
       
       Stanford::Repository.expects(:new).returns(@mock_salt_doc_repo)
       @salt_doc = Stanford::SaltDocument.new("druid:123")
    end
    
    it "#extracted_entities_to_solr should update the @solr_document hash with proper values mapped from the extracted_entities datastream" do
      @salt_doc.extracted_entities_to_solr
      @salt_doc.solr_document.should == {"company_facet"=>["KNOWLEDGE SYSTEMS LABORATORY", "Bayesian Belief Networks", "MITRE Corp", "E.I. DuPont de Nemours & Company"], "provinceorstate_facet"=>["California", "Delaware"], "organization_facet"=>["Mechanical Engineering Faculty"], "city_facet"=>["Wilmington"], "id"=>["druid:123"], "person_facet"=>["EDWARD FEIGENBAUM", "Paul Morawski", "Ed", "Palo Alto"]}
    end
    
    it "#zotero_to_solr should update the @solr_document hash with proper values mapped from the datastream" do
      @salt_doc.zotero_to_solr
      @salt_doc.solr_document.should ==   {"documentSubType_display"=>[""], "subseries_s"=>["HPP Papers, Various Authors (1 of 2)1970 -      1979"], "series_sort"=>["Accession 1986-052"], "series_facet"=>["Accession 1986-052"], "containingWork_facet"=>[""], "documentType_facet"=>["report"], "folder_s"=>["15"], "EAFHardDriveFileName_display"=>["SC340_1986"], "subseries_t"=>["HPP Papers, Various Authors (1 of 2)1970 -      1979"], "corporateEntity_t"=>["Stanford Heuristic Programming Project"], "year_s"=>["1977"], "documentType_display"=>["report"], "folder_t"=>["15"], "month_facet"=>["03"], "language_facet"=>[""], "year_t"=>["1977"], "donor_tags_facet"=>["InProgress", "Machine Learning"], "documentSubType_facet"=>[""], "extent_s"=>[""], "extent_t"=>[""], "subseries_facet"=>["HPP Papers, Various Authors (1 of 2)1970 -      1979"], "box_s"=>["36"], "title_display"=>["A Model for Learning Systems"], "subseries_display"=>["HPP Papers, Various Authors (1 of 2)1970 -      1979"], "EAFHardDriveFileName_s"=>["SC340_1986"], "series_display"=>["Accession 1986-052"], "folder_facet"=>["15"], "EAFHardDriveFileName_t"=>["SC340_1986"], "language_s"=>[""], "containingWork_display"=>[""], "box_t"=>["36"], "year_facet"=>["1977"], "identifiers_s"=>["druid:123", "SC340_1986"], "month_sort"=>["03"], "language_t"=>[""], "month_s"=>["03"], "title_s"=>["A Model for Learning Systems"], "month_t"=>["03"], "identifiers_t"=>["druid:123", "SC340_1986"], "title_t"=>["A Model for Learning Systems"], "year_display"=>["1977"], "abstract_s"=>[""], "date_display"=>["1977-03"], "month_display"=>["03"], "date_s"=>["1977-03"], "documentSubType_s"=>[""], "abstract_t"=>[""], "donor_tags_s"=>["InProgress", "Machine Learning"], "date_t"=>["1977-03"], "documentSubType_t"=>[""], "corporateEntity_facet"=>["Stanford Heuristic Programming Project"], "access_display"=>["Public"], "donor_tags_t"=>["InProgress", "Machine Learning"], "date_sort"=>["1977-03"], "public_b"=>["true"], "year_sort"=>["1977"], "containingWork_s"=>[""], "originator_s"=>["Bruce Buchanan", "Reid Smith", "Tom Mitchell", "R. Shestek"], "box_display"=>["36"], "extent_display"=>[""], "box_facet"=>["36"], "series_s"=>["Accession 1986-052"], "containingWork_t"=>[""], "series_t"=>["Accession 1986-052"], "access_facet"=>["Public"], "originator_facet"=>["Bruce Buchanan", "Reid Smith", "Tom Mitchell", "R. Shestek"], "originator_t"=>["Bruce Buchanan", "Reid Smith", "Tom Mitchell", "R. Shestek"], "folder_display"=>["15"], "abstract_display"=>[""], "documentType_s"=>["report"], "date_facet"=>["1977-03"], "language_display"=>[""], "documentType_t"=>["report"], "id"=>["druid:123"]}
    end
  end
  
  # this test the fomating of the coverage node, which is done in a private method. 
  describe "#format_coverage" do
    before(:each) do 
       @mock_salt_doc_repo = mock("Stanford::Repository")
       @mock_salt_doc_repo.stubs(:get_datastream).with("druid:123", "extracted_entities").returns(IO.read(fixture("extracted_entities2_ds.xml").path))
       @mock_salt_doc_repo.stubs(:get_datastream).with("druid:123", "zotero").returns(IO.read(fixture("zotero2_ds.xml").path))
       
       Stanford::Repository.expects(:new).returns(@mock_salt_doc_repo)
       @salt_doc = Stanford::SaltDocument.new("druid:123")
    end
   
   it "should get all the box, folder, subseries information correctly, even if the subseries text is screwy." do
      @salt_doc.zotero_to_solr
      @salt_doc.solr_document.should ==  {"documentSubType_display"=>[""], "subseries_s"=>["\"An Information Processing Theory of Verbal Learning\" -      EAF's Carnegie Mellon Thesis, published by RAND Corporation1959"], "series_sort"=>["Accession 2005-101"], "series_facet"=>["Accession 2005-101"], "containingWork_facet"=>[""], "folder_s"=>["6"], "documentType_facet"=>["report"], "EAFHardDriveFileName_display"=>["00010316"], "subseries_t"=>["\"An Information Processing Theory of Verbal Learning\" -      EAF's Carnegie Mellon Thesis, published by RAND Corporation1959"], "corporateEntity_t"=>["RAND Corporation"], "year_s"=>["1959"], "documentType_display"=>["report"], "folder_t"=>["6"], "notes_display"=>["<p>Additional informationX1Y2Z3</p>\n<p>Document TypeX1Y2Z3 Report<br />Corporate EntityX1Y2Z3 RAND Corporation<br />NumberX1Y2Z3 P-1817<br />PagesX1Y2Z3 165</p>", "<p>Feigenbaum's thesis, published as a RAND Corporation       \"paper\"</p>"], "month_facet"=>["10"], "day_sort"=>["09"], "language_facet"=>[""], "year_t"=>["1959"], "donor_tags_facet"=>["EPAM", "InProgress", "IPL-V", "RAND"], "documentSubType_facet"=>[""], "extent_s"=>["165"], "extent_t"=>["165"], "notes_s"=>["<p>Additional informationX1Y2Z3</p>\n<p>Document TypeX1Y2Z3 Report<br />Corporate EntityX1Y2Z3 RAND Corporation<br />NumberX1Y2Z3 P-1817<br />PagesX1Y2Z3 165</p>", "<p>Feigenbaum's thesis, published as a RAND Corporation       \"paper\"</p>"], "subseries_facet"=>["\"An Information Processing Theory of Verbal Learning\" -      EAF's Carnegie Mellon Thesis, published by RAND Corporation1959"], "box_s"=>["46"], "title_display"=>["\"An Information Processing Theory of Verbal Learning\" - EAF's Carnegie Mellon Thesis, published by RAND Corporation1959"], "subseries_display"=>["\"An Information Processing Theory of Verbal Learning\" -      EAF's Carnegie Mellon Thesis, published by RAND Corporation1959"], "EAFHardDriveFileName_s"=>["00010316"], "notes_t"=>["<p>Additional informationX1Y2Z3</p>\n<p>Document TypeX1Y2Z3 Report<br />Corporate EntityX1Y2Z3 RAND Corporation<br />NumberX1Y2Z3 P-1817<br />PagesX1Y2Z3 165</p>", "<p>Feigenbaum's thesis, published as a RAND Corporation       \"paper\"</p>"], "series_display"=>["Accession 2005-101"], "folder_facet"=>["6"], "EAFHardDriveFileName_t"=>["00010316"], "language_s"=>[""], "containingWork_display"=>[""], "box_t"=>["46"], "year_facet"=>["1959"], "identifiers_s"=>["druid:123", "00010316"], "month_sort"=>["10"], "language_t"=>[""], "month_s"=>["10"], "title_s"=>["\"An Information Processing Theory of Verbal Learning\" - EAF's Carnegie Mellon Thesis, published by RAND Corporation1959"], "month_t"=>["10"], "identifiers_t"=>["druid:123", "00010316"], "title_t"=>["\"An Information Processing Theory of Verbal Learning\" - EAF's Carnegie Mellon Thesis, published by RAND Corporation1959"], "day_display"=>["09"], "year_display"=>["1959"], "abstract_s"=>[""], "date_display"=>["1959-10-09"], "month_display"=>["10"], "date_s"=>["1959-10-09"], "documentSubType_s"=>[""], "abstract_t"=>[""], "donor_tags_s"=>["EPAM", "InProgress", "IPL-V", "RAND"], "date_t"=>["1959-10-09"], "documentSubType_t"=>[""], "corporateEntity_facet"=>["RAND Corporation"], "access_display"=>["Private"], "donor_tags_t"=>["EPAM", "InProgress", "IPL-V", "RAND"], "date_sort"=>["1959-10-09"], "year_sort"=>["1959"], "containingWork_s"=>[""], "containingWork_t"=>[""], "series_s"=>["Accession 2005-101"], "originator_s"=>["Feigenbaum"], "box_display"=>["46"], "extent_display"=>["165"], "box_facet"=>["46"], "series_t"=>["Accession 2005-101"], "access_facet"=>["Private"], "originator_t"=>["Feigenbaum"], "originator_facet"=>["Feigenbaum"], "day_facet"=>["09"], "day_s"=>["09"], "abstract_display"=>[""], "documentType_s"=>["report"], "date_facet"=>["1959-10-09"], "folder_display"=>["6"], "language_display"=>[""], "day_t"=>["09"], "documentType_t"=>["report"], "id"=>["druid:123"]}
   end 
   
    
  end
  
  
  
end
  
  