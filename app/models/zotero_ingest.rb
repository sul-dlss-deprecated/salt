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

def process_file
  unless self.filename.nil?
    self.save!
    self.start_date = render_now
    
    
    log_message("[#{self.start_date}] - Starting Zotero Ingest. ")
    log_message("Process file at #{self.filename}")
    
    timestamp = render_now
    
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
    self.finish_date = render_now
    
    update_index(zotero_parser.processed_druids)
    
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
    ZoteroIngest.update(self.id, { :message => self.message << "[#{render_now}] : #{msg}\n"  } )
    self.reload
  end


end
