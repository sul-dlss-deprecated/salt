#!/usr/bin/env ruby
require 'rubygems'
require 'simple-daemon'
require 'logger'


#
# This is a simple dameon that runs in order to move files from the AFS space into the server's local
# drivespace. It should be run as the lyberadmin user, not as the apache user.  
#

class Processor < SimpleDaemon::Base
  
  SimpleDaemon::WORKING_DIRECTORY = "/home/lyberadmin/bin"
  REMOTE_DIR = "/afs/ir/group/salt_project/zotero_dropoff"
  LOCAL_DIR = "/var/www/saltworks/tmp/"


  def self.start
    
    @logger = Logger.new('logfile.log')
    @logger.level = Logger::INFO
    @logger.info "Starting daemon."    
    
    loop do  
        Dir.glob(File.join(REMOTE_DIR, "*.rdf")).each do |f|
          @logger.info "File #{f} found. Sleeping to ensure copy is completed."
          sleep(1000) # sleep to make sure the file is there
          FileUtils.mv(f, LOCAL_DIR)
          @logger.info "File #{f} moved to #{LOCAL_DIR}."
        end
    end
     
  end

  def self.stop
    puts "Stopping processor  "
    @logger.info "Stopping daemon."
    @logger.close
  end
end

Processor.daemonize
