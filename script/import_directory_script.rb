#!/usr/bin/env ruby
require 'rubygems'
require 'logger'
require 'fileutils'
require File.expand_path("../../config/environment", __FILE__)


class ImportDirectoryScript

  REMOTE_DIR = DIRECTORY_WATCHER_DIR
  LOCAL_DIR = File.join(Rails.root, 'tmp')

  @logger = Logger.new(File.join(Rails.root, 'log', 'import_directory.log'))
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