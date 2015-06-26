require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


describe Stanford::Indexer do
  
  describe "#new" do
    
    it "should have all relative stuff initilized" do
        
        @mock_zotero_index = double("ZoteroIndex")
        
        @mock_indexer_repo = double("Stanford::Repository")
        @mock_indexer_repo.stub(:initialize_queue => ["foo:bar", "bar:foo"])
        expect(Stanford::Repository).to receive(:new).and_return(@mock_indexer_repo)
        @indexer = Stanford::Indexer.new(["foo:bar", "bar:foo" ], @mock_zotero_index)
        
        expect(@indexer.queue).to eq(["foo:bar", "bar:foo"])
        expect(@indexer.zotero_ingest).to eq(@mock_zotero_index)
      
    end
    
    
  end
  
   
  describe "starting an indexer" do
    
    before(:each) do 
      @mock_indexer_repo = double("Stanford::Repository")
      @mock_indexer_repo.stub(:initialize_queue => ["foo:bar", "bar:foo"])
      expect(Stanford::Repository).to receive(:new).and_return(@mock_indexer_repo)
      @indexer = Stanford::Indexer.new([],ZoteroIngest.new)
      @indexer.zotero_ingest.save
    end
    
    it "should get a queue of druids for processing and should have the fixture object in it" do
    
      expect(@indexer.queue).to be_kind_of(Array)
      expect(@indexer.queue.include?("foo:bar")).to be true
      expect(@indexer.queue.include?("bar:foo")).to be true
      expect(@indexer.queue.include?("druid:bb047vy0535")).to be false
      
    end
    
    it "should run and index each of the objects in the queue" do
      
      expect(@indexer).to receive(:process_item).with("foo:bar").once
      expect(@indexer).to receive(:process_item).with("bar:foo").once
      expect(@indexer).to receive(:process_item).with("druid:bb047vy0535").never
      @indexer.process_queue
      
    end
    
    it "should update the records" do
       
        expect(@indexer).to receive(:process_item).with("foo:bar").once
        expect(@indexer).to receive(:process_item).with("bar:foo").once
        expect(@indexer).to receive(:process_item).with("druid:bb047vy0535").never
        
        Time.stub(:now => "NOW!")
            
        @indexer.process_queue
    end
    
    it "it should index when processing an item" do
      
       mock_salt_doc = double("Stanford::SaltDocument")
       mock_solr_doc = double("SolrDocument")
       mock_salt_doc.stub(:solr_document => mock_solr_doc)
     
       mock_salt_doc.stub(:to_solr => [])
       
       
       mock_connection = double("SolrConnection")
       mock_connection.stub(:add => true)
       mock_connection.stub(:update => true)
       @indexer.solr = mock_connection
       
       expect(Stanford::SaltDocument).to receive(:new).with("foo:bar", {:repository => @mock_indexer_repo}).and_return(mock_salt_doc)
               
       @indexer.process_item("foo:bar")
        
    end
  
    it "should rescue if there's an SocketError " do
       mock_salt_doc = double("Stanford::SaltDocument")
       mock_solr_doc = double("SolrDocument")
       mock_salt_doc.stub(:solr_document => mock_solr_doc)
     
       mock_salt_doc.stub(:to_solr => [])
      
      
       mock_connection = double("SolrConnection")
       allow(mock_connection).to receive(:add).and_raise(Errno::EHOSTUNREACH)
       @indexer.solr = mock_connection
       expect(@indexer).to receive(:log_message).once.with("Indexing item foo:bar")
       expect(@indexer).to receive(:log_message).once.with("SocketError")
        
      expect(Stanford::SaltDocument).to receive(:new).with("foo:bar", {:repository => @mock_indexer_repo}).and_return(mock_salt_doc)
      
      @indexer.process_item("foo:bar") 
      
    end
  
     it "should rescue if there's an another kind of error " do
         mock_salt_doc = double("Stanford::SaltDocument")
         mock_solr_doc = double("SolrDocument")
         mock_salt_doc.stub(:solr_document => mock_solr_doc)

         mock_salt_doc.stub(:to_solr => [])


         mock_connection = double("SolrConnection")
         allow(mock_connection).to receive(:add).and_raise(Net::HTTPServerException.new "There's a problems", nil)
         @indexer.solr = mock_connection
         
         expect(@indexer).to receive(:log_message).once.with('Indexing item foo:bar')
         expect(@indexer).to receive(:log_message).once.with('There\'s a problems')
        

        expect(Stanford::SaltDocument).to receive(:new).with("foo:bar", {:repository => @mock_indexer_repo}).and_return(mock_salt_doc)

        @indexer.process_item("foo:bar") 
        

      end
  
  
  
  end
  
  
    
    
    
  
  
end 
