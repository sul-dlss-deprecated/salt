require 'lib/stanford/zotero_parser'


# this is used to track ingested zotero export files. The ZoteroDirectoryWatcher (script/background/zotero_directory_watcher.rb) deamon kicks off the processes.

class ZoteroIngest < ActiveRecord::Base

  attr_accessor :inprocess_directory
  attr_accessor :out_directory
  attr_accessor :error_directory
  attr_accessor :rdf_file
  attr_accessor :processing_file





def after_initialize
    self.message ||= ""
    @inprocess_directory = File.join(DIRECTORY_WATCHER_DIR, "inprocess")
    @out_directory = File.join(DIRECTORY_WATCHER_DIR, "completed")
    @error_directory = File.join(DIRECTORY_WATCHER_DIR, "error")
    make_directories    
end

#
# This method is used by the zotero_ingest background daemon to process new files for ingest. 
def process_file
  unless self.filename.nil?
    
    self.save #we need to first save to ensure we have a proper obj ID. 
    
    timestamp = render_now
    
    log_message("[#{timestamp}] - Starting Zotero Ingest. ")
    log_message("Process file at #{self.filename}")
    
    
    @processing_file = File.join(@inprocess_directory, "#{File.basename(self.filename,".rdf")}-#{timestamp}.rdf" )
    FileUtils.mv(self.filename,  @processing_file)

    log_message("Moving #{file} to  #{@processing_file}")
    log_message("Starting ZoteroParser")
   
    
    zotero_parser = Stanford::ZoteroParser.new(@processing_file, self)
    zotero_parser.process_document

    outdir = File.join(@out_directory, timestamp)
    FileUtils.mkpath(outdir)
    FileUtils.mv(@processing_file, outdir )

    log_message("Parser completed. Moving #{@processing_file} to #{File.join(outdir, filename )}")
   
    
    update_index(zotero_parser.processed_druids)
    check_data(File.join(outdir, @processing_file ))
    
    
    log_message(zotero_parser.processed_druids.join(" , "))
    
    self.save! 
  end

rescue => e
  puts "Errors: #{e.inspect} #{e.backtrace.join('\n')}"
  log_message("Zotero Import Error -- File: #{File.join(@inprocess_directory, filename)}")
  log_message("Errors: #{e.inspect} #{e.backtrace.join('\n')}")
  
   outdir = File.join(@error_directory, timestamp)
   FileUtils.mkpath(outdir)
   FileUtils.mv(@processing_file, outdir )
   File.open(File.join(outdir, "error.txt"), "w") { |f| f << "#{e.inspect} #{e.backtrace.join('\n')}" }
end


# takes an array of druids to be updated and indexes the documents into solr.
 def update_index(druids=[])
   index = Stanford::Indexer.new(druids, self)
   index.process_queue
 end



private

  def make_directories
      [@inprocess_directory, @out_directory, @error_directory].each {|dir| FileUtils.mkpath(dir)}
  end
  
  
  # convience method to generate timestamp directory names
  def render_now
    return Time.now.strftime("%Y-%m-%d_%H-%M-%s")  
  end

  def log_message(msg)
    logger.info msg
  end

  def check_data(zotero_xml_file)
    checkr = Stanford::SolrCheckr.new(zotero_xml_file, self)
    checkr.check_documents
  end
  

end
