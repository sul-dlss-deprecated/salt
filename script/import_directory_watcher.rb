#!/usr/bin/env ruby

require 'rubygems'
require 'directory_watcher'
require 'logger'

module Stanford
  
  class ImportDirectoryWatcher
    
    attr_accessor :remote_directoy
    attr_accessor :local_directory  
    attr_accessor :dw
    attr_accessor :logger
   
    
    # http://codeforpeople.rubyforge.org/directory_watcher/classes/DirectoryWatcher.html
    # new object takes string  directory to be watched, the integer interval between checks, and interger of the amount of checks before it's declared stabl
    
    # this script is written to move files form the AFS space into the application's local directory space for processing. 
    # It should be run as a user with access ot the AFS space (i.e. lyberadmin) and not as as the rails user (apache).
    
    def initialize(remote_directory='/afs/ir/group/salt_project/zotero_dropoff', local_directory="/tmp",  interval=5, stable=2 )
      
      if File.exists?(remote_directory) and File.exists?(local_directory)
         
         @remote_directory = remote_directory
         @local_directory = local_directory
         @logger = Logger.new(STDOUT)
                    
         @dw = DirectoryWatcher.new @remote_directory, :glob => '*.xml', :persist => "/tmp/watcher.log"
         @dw.interval = interval
         @dw.stable = stable
       
        @dw.add_observer do |*args| 
          args.each  do |event| 
            puts event
            if event.type == :stable
              
              log_message("#{event.path} is now #{event.type}.")
              FileUtils.mv(event.path, @local_directory)
            
              log_message("#{event.path} moved to #{@local_directory}")
            end   
          end 
        end
             
       
      else
        raise "You need to ensure that the remote and local directories exists."
      end
    end
    
   
 
   # convience method to generate timestamp directory names
   def self.render_now
     return Time.now.strftime("%Y-%m-%d_%H-%M-%s")  
   end

   def start
      @dw.start
      gets
    end

   private
   
   
   def log_message(msg)
      @logger << msg
   end
   
  end
end


# This is the equivalent of a java main method
if __FILE__ == $0
  dw = Stanford::ImportDirectoryWatcher.new
  dw.start
end

