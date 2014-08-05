require 'spec_helper'

describe ZoteroIngest do
  
  before(:each) do
      
      # there's a lot of file moving around that needs to happen. 
      # 1. file is seen into DIRECTORY_WATCHER_DIR, 2. file is moved to inprocess directory and given time stamp. 3. when process is completed, file is moved into completed directory.
      # else, it's moved into the error directory with a error.txt file with backtrace. 
    @file = fixture('singleton_zotero_export.xml').path #our source file.
    @inprocess_file = File.join(Settings.directory_watcher.local, "inprocess", "#{File.basename(@file)}-1969-04-11_4:20.rdf") #what our file should look like when it's moved into the process dir
    @completed_directory = File.join(Settings.directory_watcher.local, "completed", "1969-04-11_4:20" ) # file in error directory
    @error_directory =  File.join(Settings.directory_watcher.local, "error", "1969-04-11_4:20") # file in error directory
  end
  

  
  describe "#process_file" do
    
    it "should do nothing if the filename is not set" do
      z = ZoteroIngest.new
      z.process_file
      z.should_receive(:save).never 
    end
    
    it "should process the file correctly" do
      @zi = ZoteroIngest.new(:filename => @file )
      
      @zi.should_receive(:render_now).at_least(:once).and_return("1969-04-11_4:20")  #timestamp
      @zi.should_receive(:update_index).once.and_return(true)
      
      
      zp = mock("ZoteroParser")
      zp.should_receive(:process_document).once
      zp.should_receive(:processed_druids).twice.and_return(["test:druid"])
      
      sc = mock("SolrCheckr")
      sc.should_receive(:check_documents).once
      
      Stanford::ZoteroParser.should_receive(:new).with(@inprocess_file, @zi).and_return(zp)
      Stanford::SolrCheckr.should_receive(:new).with(@inprocess_file, @zi).and_return(sc)
      
      FileUtils.should_receive(:mv).with(@file, @inprocess_file ).once
      FileUtils.should_receive(:mv).with(@inprocess_file , @completed_directory ).once
      
      @zi.process_file
    
    end
    
    it "should move the file to the error directory is a problem occurs" do
      @zi = ZoteroIngest.new(:filename => @file )
      @zi.should_receive(:render_now).at_least(:once).and_return("1969-04-11_4:20")  #timestamp
    
      
      FileUtils.should_receive(:mv).with(@file, @inprocess_file ).once
      FileUtils.should_receive(:mv).with(@inprocess_file , @error_directory ).once
      
      @zi.process_file
    end
    
  end
  
  
  describe "#update_index" do
    
    it "should update the index when given an array of druids" do
      @zi = ZoteroIngest.new()
      druids = ["foo:bar", "bar:foo", "bar:bar", "foo:foo"]
      mock_indexer = mock("Stanford::Indexer")
      mock_indexer.should_receive(:process_queue).and_return(true)
      Stanford::Indexer.should_receive(:new).with(druids, @zi).and_return(mock_indexer)  
      
      @zi.update_index(druids).should be_true 
    end
    
  end
  
  
end
