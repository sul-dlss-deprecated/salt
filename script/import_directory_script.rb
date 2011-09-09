#!/usr/bin/env ruby
require 'rubygems'
require 'logger'
require 'fileutils'


class ImportDirectoryScript
  
  REMOTE_DIR = "/afs/ir/group/salt_project/zotero_dropoff"
  LOCAL_DIR = "/var/www/saltworks/tmp/"
  
  @logger = Logger.new('/home/lyberadmin/bin/import_directory.log')
  @logger.level = Logger::INFO
  @logger.info "Starting directory check of #{REMOTE_DIR}."
  
  @logger.info  `/home/lyberadmin/bin/renew-ticket.sh`
  
  Dir.glob(File.join(REMOTE_DIR, "*.rdf")).each do |f|
      @logger.info "File #{f} found. Sleeping to ensure copy is completed."
      sleep(100) # sleep to make sure the file is there
      FileUtils.mv(f, LOCAL_DIR)
      @logger.info "File #{f} moved to #{LOCAL_DIR}."
  end    
  
  @logger.info "Check completed."
  
  
end