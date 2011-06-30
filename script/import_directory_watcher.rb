#!/usr/bin/env ruby

require 'rubygems'
require 'fssm'
require 'logger'

module Stanford
  

  
  
  class FileObject
    
    attr_accessor :remote_file
    attr_accessor :local_directory  
    attr_accessor :logger
   
    
    # http://codeforpeople.rubyforge.org/directory_watcher/classes/DirectoryWatcher.html
    # new object takes string  directory to be watched, the integer interval between checks, and interger of the amount of checks before it's declared stabl
    
    # this script is written to move files form the AFS space into the application's local directory space for processing. 
    # It should be run as a user with access ot the AFS space (i.e. lyberadmin) and not as as the rails user (apache).
    
    def initialize(remote_file, local_directory="/tmp")
        
 
         @remote_file = remote_file
         @local_directory = local_directory
         @logger = Logger.new('logfile.log')

         
         @logger.level = Logger::INFO      
    end
    
 

   def updated
     log_message("Updated -- #{@remote_file}")
     FileUtils.mv(@remote_file, @local_directory)
   end
   
    def deleted
      log_message("Deleted -- #{@remote_file}")
    end
   
   # when a file is created, it needs to be sure that it is copied completely over.
   def created 
     log_message("Created -- #{@remote_file}")  
     sleep(5)
     FileUtils.touch(@remote_file) #this should trigger an update. 
   end
   
  protected
   
   def log_message(msg)
      @logger.info "#{msg}\n"
   end
   
  end
  
  class ImportDirectoryWatcher
      attr_accessor :remote_directoy
      attr_accessor :dw
      
      def initialize(remote_directory='/afs/ir/group/salt_project/zotero_dropoff')
        File.exists?(remote_directory) ?  @remote_directory = remote_directory : raise {"You need to ensure that your remote directory exists."}
      rescue => e
       p e.inspect
       
      end  
      
      def run
          FSSM::monitor(@remote_directory, '**/*') do 
               update { |base, relative| Stanford::FileObject.new(File.join(base, relative)).updated }
               delete { |base, relative| Stanford::FileObject.new(File.join(base, relative)).deleted } 
               create { |base, relative| Stanford::FileObject.new(File.join(base, relative)).created }  
          end
      end
    
      def stop
        @dw.stop
      end
    
  end
  
  
  
end





# This is the equivalent of a java main method
if __FILE__ == $0
 dw = Stanford::ImportDirectoryWatcher.new
  dw.run
end

