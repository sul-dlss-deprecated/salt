require 'rubygems'
require 'directory_watcher'
require 'lib/stanford/zotero_parser'


module Stanford
  
  class ImportDirectoryWatcher
    
    attr_accessor :dw
    attr_accessor :import_directory
    attr_accessor :inprocess_directory
    attr_accessor :error_directory
    attr_accessor :out_directory
    
   
    
    # http://codeforpeople.rubyforge.org/directory_watcher/classes/DirectoryWatcher.html
    # new object takes string  directory to be watched, the integer interval between checks, and interger of the amount of checks before it's declared stabl
    def initialize(afs_upload_directory='/afs/ir/group/salt_project/zotero_dropoff', interval=1, stable=2 )
      
      if File.exists?(afs_upload_directory)
         
         @directory = afs_upload_directory
         @inprocess_directory = File.join(@directory, "inprocess")
         @out_directory = File.join(@directory, "completed")
         @error_directory = File.join(@directory, "error")
         
         [@inprocess_directory, @out_directory, @error_directory].each {|dir| FileUtils.mkpath(dir)}
                  
         @dw = DirectoryWatcher.new @directory, :glob => '*.xml', :persist => "/tmp/watcher.log"
         @dw.interval = interval
         @dw.stable = stable
       
        @dw.add_observer do |*args| 
          args.each  do |event| 
            puts event
            if event.type == :stable
              
              log_message("#{event.path} is now #{event.type}.")
              druids = process_file(event.path) #update fedora
              log_message("Process complete. Updating Index")
              update_index(druids) #update solr with updated druids.
            end   
          end 
        end
             
        dw.start

      else
        raise "DIRECTORY_WATCHER_DIR not set"
      end
    end
    
    # this method takes a filename string, run the zotero parser, then moves the file into a done directory
    def process_file(file)
      log_message("Process file at #{file}")
      
      timestamp = Stanford::ImportDirectoryWatcher.render_now
      filename = File.join( "#{File.basename(file,".xml")}-#{timestamp}.xml" ) 
      FileUtils.mv(file, File.join(@inprocess_directory, filename))
      
      log_message("Moving #{file} to #{File.join(@inprocess_directory, filename)}")
      log_message("Starting ZoteroParser")
      
      zotero = Stanford::ZoteroParser.new(File.join(@inprocess_directory, filename))
      zotero.process_document
      
      outdir = File.join(@out_directory, timestamp)
      FileUtils.mkpath(outdir)
      FileUtils.mv(File.join(@inprocess_directory, filename), File.join(outdir, filename ))
      
      log_message("Parser completed. Moving #{File.join(@inprocess_directory, filename)} to #{File.join(outdir, filename )}")
      
      return zotero.processed_druids
      
    rescue => e
      log_message("Zotero Import Error -- File: #{File.join(@inprocess_directory, filename)}")
      log_message("Errors: #{e.inspect} #{e.backtrace.join('\n')}")
      
       outdir = File.join(@directory, "error", timestamp)
       FileUtils.mkpath(outdir)
       FileUtils.mv(File.join(@inprocess_directory, filename), File.join(outdir, filename ))
       File.open(File.join(outdir, "error.txt"), "w") { |f| f << "#{e.inspect} #{e.backtrace.join('\n')}" }
       
   
       
    end
       
   # takes an array of druids to be updated and indexes the documents into solr.        
   def update_index(druids=[])
     index = Stanford::Indexer.new(druids)
     index.process_queue
   end

   # convience method to generate timestamp directory names
   def self.render_now
     return Time.now.strftime("%Y-%m-%d_%H-%M-%s")  
   end

   private
   
   def log_message(msg)
     if  defined?(Rails) == "constant" 
       Rails.logger.info "Stanford::ImportDirectoryWatcher : #{msg} "  
     end
   end
   
  end
end