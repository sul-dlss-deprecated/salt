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
      expect(z).to receive(:save).never 
    end
    
    it "should process the file correctly" do
      @zi = ZoteroIngest.new(:filename => @file )
      
      expect(@zi).to receive(:render_now).at_least(:once).and_return("1969-04-11_4:20")  #timestamp
      expect(@zi).to receive(:update_index).once.and_return(true)
      
      
      zp = double("ZoteroParser")
      expect(zp).to receive(:process_document).once
      expect(zp).to receive(:processed_druids).twice.and_return(["test:druid"])
      
      sc = double("SolrCheckr")
      expect(sc).to receive(:check_documents).once
      
      expect(Stanford::ZoteroParser).to receive(:new).with(@inprocess_file, @zi).and_return(zp)
      expect(Stanford::SolrCheckr).to receive(:new).with(@inprocess_file, @zi).and_return(sc)
      
      expect(FileUtils).to receive(:mv).with(@file, @inprocess_file ).once
      expect(FileUtils).to receive(:mv).with(@inprocess_file , @completed_directory ).once
      
      @zi.process_file
    
    end
    
    it "should move the file to the error directory is a problem occurs" do
      @zi = ZoteroIngest.new(:filename => @file )
      expect(@zi).to receive(:render_now).at_least(:once).and_return("1969-04-11_4:20")  #timestamp
    
      
      expect(FileUtils).to receive(:mv).with(@file, @inprocess_file ).once
      expect(FileUtils).to receive(:mv).with(@inprocess_file , @error_directory ).once
      
      @zi.process_file
    end
    
  end
  
  
  describe "#update_index" do
    
    it "should update the index when given an array of druids" do
      @zi = ZoteroIngest.new()
      druids = ["foo:bar", "bar:foo", "bar:bar", "foo:foo"]
      mock_indexer = double("Stanford::Indexer")
      expect(mock_indexer).to receive(:process_queue).and_return(true)
      expect(Stanford::Indexer).to receive(:new).with(druids, @zi).and_return(mock_indexer)  
      
      expect(@zi.update_index(druids)).to be true 
    end
    
  end
  
  
end
