require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'lib/stanford/indexer'


describe Stanford::Indexer do
  
  describe "#new" do
    
    it "should have all relative stuff initilized" do
        
        @mock_zotero_index = mock("ZoteroIndex")
        
        @mock_indexer_repo = mock("Stanford::Repository")
        @mock_indexer_repo.stubs(:initialize_queue).returns(["foo:bar", "bar:foo"])
        Stanford::Repository.expects(:new).returns(@mock_indexer_repo)
        @indexer = Stanford::Indexer.new(["foo:bar", "bar:foo" ], @mock_zotero_index)
        
        @indexer.queue.should == ["foo:bar", "bar:foo"]
        @indexer.zotero_ingest.should == @mock_zotero_index
      
    end
    
    
  end
  
   
  describe "starting an indexer" do
    
    before(:each) do 
      @mock_indexer_repo = mock("Stanford::Repository")
      @mock_indexer_repo.stubs(:initialize_queue).returns(["foo:bar", "bar:foo"])
      Stanford::Repository.expects(:new).returns(@mock_indexer_repo)
      @indexer = Stanford::Indexer.new([],ZoteroIngest.new)
      @indexer.zotero_ingest.save
    end
    
    it "should get a queue of druids for processing and should have the fixture object in it" do
    
      @indexer.queue.should be_kind_of(Array)
      @indexer.queue.include?("foo:bar").should be_true
      @indexer.queue.include?("bar:foo").should be_true
      @indexer.queue.include?("druid:bb047vy0535").should be_false
      
    end
    
    it "should run and index each of the objects in the queue" do
      
      @indexer.expects(:process_item).with("foo:bar").once
      @indexer.expects(:process_item).with("bar:foo").once
      @indexer.expects(:process_item).with("druid:bb047vy0535").never
      @indexer.process_queue
      
    end
    
    it "should update the records" do
       
        @indexer.expects(:process_item).with("foo:bar").once
        @indexer.expects(:process_item).with("bar:foo").once
        @indexer.expects(:process_item).with("druid:bb047vy0535").never
        
        Time.expects(:now).returns("NOW!").times(8)
            
        @indexer.process_queue
    end
    
    it "it should index when processing an item" do
      
       mock_salt_doc = mock("Stanford::SaltDocument")
       mock_solr_doc = mock("SolrDocument")
       mock_salt_doc.stubs(:solr_document).returns(mock_solr_doc)
     
       mock_salt_doc.stubs(:to_solr).returns([])
       
       
       mock_connection = mock("SolrConnection")
       mock_connection.stubs(:add).returns(true)
       mock_connection.stubs(:update).returns(true)
       @indexer.solr = mock_connection
       
       Stanford::SaltDocument.expects(:new).with("foo:bar", {:repository => @mock_indexer_repo}).returns(mock_salt_doc)
               
       @indexer.process_item("foo:bar")
        
    end
  
    it "should rescue if there's an SocketError " do
       mock_salt_doc = mock("Stanford::SaltDocument")
       mock_solr_doc = mock("SolrDocument")
       mock_salt_doc.stubs(:solr_document).returns(mock_solr_doc)
     
       mock_salt_doc.stubs(:to_solr).returns([])
      
      
       mock_connection = mock("SolrConnection")
       mock_connection.stubs(:add).raises(Errno::EHOSTUNREACH)
       @indexer.solr = mock_connection
       @indexer.expects(:log_message).once.with("Indexing item foo:bar")
       @indexer.expects(:log_message).once.with("SocketError")
        
      Stanford::SaltDocument.expects(:new).with("foo:bar", {:repository => @mock_indexer_repo}).returns(mock_salt_doc)
      
      @indexer.process_item("foo:bar") 
      
    end
  
     it "should rescue if there's an another kind of error " do
         mock_salt_doc = mock("Stanford::SaltDocument")
         mock_solr_doc = mock("SolrDocument")
         mock_salt_doc.stubs(:solr_document).returns(mock_solr_doc)

         mock_salt_doc.stubs(:to_solr).returns([])


         mock_connection = mock("SolrConnection")
         mock_connection.stubs(:add).raises(Net::HTTPServerException, "There's a problems")
         @indexer.solr = mock_connection
         
         @indexer.expects(:log_message).once.with('Indexing item foo:bar')
         @indexer.expects(:log_message).once.with('wrong number of arguments (1 for 2)')
        

        Stanford::SaltDocument.expects(:new).with("foo:bar", {:repository => @mock_indexer_repo}).returns(mock_salt_doc)

        @indexer.process_item("foo:bar") 
        

      end
  
  
  
  end
  
  
    
    
    
  
  
end 
