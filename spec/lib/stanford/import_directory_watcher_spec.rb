require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'lib/stanford/import_directory_watcher'
require 'Tmpdir'

describe Stanford::ImportDirectoryWatcher do 
  
  before(:all) do
     @directory = DIRECTORY_WATCHER_DIR # For testing, the watch directory is names a random string in the system's temp directory
   end
  
  
  describe "#new" do
    
 
    it "should make the directories needed to process document when itialized" do
      File.exists?(File.join(@directory, "inprocess")).should be_true
      File.exists?(File.join(@directory, "completed")).should be_true
      File.exists?(File.join(@directory, "error")).should be_true
    end
    
    it "should raise an error if the directory does not exists" do
      lambda { Stanford::ImportDirectoryWatcher.new("/some/fake/path")}.should raise_exception
    end
  end
  
  describe "#process_file" do 
    
    it "should process the files added to the directory" do #not really sure how to test this right now
      pending
      Stanford::ImportDirectoryWatcher.expects(:render_now).returns("timestamp")
      zp = mock("Stanford::ZoteroParser")
      zp.expects(:start).returns(true)
      Stanford::ZoteroParser.expects(:new).returns(zp)
    
      FileUtils.cp(fixture("singleton_zotero_export.xml").path, @directory)
      sleep 5
    end
    
    
  end
  
end