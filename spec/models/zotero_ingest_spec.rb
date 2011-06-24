require 'spec_helper'

describe ZoteroIngest do
  
  before(:each) do
      
      # there's a lot of file moving around that needs to happen. 
      # 1. file is seen into DIRECTORY_WATCHER_DIR, 2. file is moved to inprocess directory and given time stamp. 3. when process is completed, file is moved into completed directory.
      # else, it's moved into the error directory with a error.txt file with backtrace. 
    @file = fixture('singleton_zotero_export.xml').path #our source file.
    @inprocess_file = File.join(DIRECTORY_WATCHER_DIR, "inprocess", "#{File.basename(@file)}-1969-04-11_4:20.rdf") #what our file should look like when it's moved into the process dir
    @completed_directory = File.join(DIRECTORY_WATCHER_DIR, "completed", "1969-04-11_4:20" ) # file in error directory
    @error_directory =  File.join(DIRECTORY_WATCHER_DIR, "error", "1969-04-11_4:20") # file in error directory
  end
  

  
  describe "#process_file" do
    
    it "should do nothing if the filename is not set" do
      z = ZoteroIngest.new
      z.process_file
      z.expects(:save).never 
    end
    
    it "should process the file correctly" do
      @zi = ZoteroIngest.new(:filename => @file )
      
      @zi.expects(:render_now).at_least_once.returns("1969-04-11_4:20")  #timestamp
      @zi.expects(:update_index).once.returns(true)
      
      
      zp = mock("ZoteroParser")
      zp.expects(:process_document).once
      zp.expects(:processed_druids).twice.returns(["test:druid"])
      Stanford::ZoteroParser.expects(:new).with(@inprocess_file, @zi).returns(zp)
      
      FileUtils.expects(:mv).with(@file, @inprocess_file ).once
      FileUtils.expects(:mv).with(@inprocess_file , @completed_directory ).once
      
      @zi.process_file
    
    end
    
    it "should move the file to the error directory is a problem occurs" do
      @zi = ZoteroIngest.new(:filename => @file )
      @zi.expects(:render_now).at_least_once.returns("1969-04-11_4:20")  #timestamp
    
      
      FileUtils.expects(:mv).with(@file, @inprocess_file ).once
      FileUtils.expects(:mv).with(@inprocess_file , @error_directory ).once
      
      @zi.process_file
    end
    
    
  end
  
  
  
end
