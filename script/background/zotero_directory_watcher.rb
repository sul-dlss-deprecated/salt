#!/usr/bin/env ruby

# Load Rails.
ENV['RAILS_ENV'] = ARGV[1] if ARGV[1]
require File.dirname(__FILE__) + '/../../config/environment.rb'

# TODO: More ARGV-based setup here.


# Restore timestamps in the log.
class Logger
  def format_message(severity, timestamp, progname, msg)
    "#{severity[0,1]} [#{timestamp} PID:#{$$}] #{progname}: #{msg}\n"
  end
end


require 'simple-daemon'
class ZoteroDirectoryWatcher < SimpleDaemon::Base
  SimpleDaemon::WORKING_DIRECTORY = File.join(Rails.root, 'log')

  def self.start
    STDOUT.sync = true
    @logger = Logger.new(File.join(Rails.root, 'log', 'zotero_dir_watcher.log'))
    @logger.level = Logger::INFO


    if Rails.env.development?
      # Disable SQL logging in debugging.
			# This is handy if your daemon queries the database often.
      ActiveRecord::Base.logger.level = Logger::INFO
    end

   @logger.info "Starting daemon ZoteroDirectoryWatcher"
   @logger.info "Watching #{Settings.directory_watcher.local}"

    loop do
      begin

	# Keep renewing the kerberos ticket and keep moving any new files
    	@logger.info  `/home/lyberadmin/bin/renew-ticket.sh`
    	@logger.info  `ruby #{Rails.root}/script/import_directory_script.rb`

         zotero = nil
        Dir.glob(File.join(Settings.directory_watcher.local, "*.rdf")).each do |f|
          @logger.info "glob"
          @logger.info "starting #{f}"
          zotero = ZoteroIngest.new(:filename => f)
          zotero.process_file
          zotero.save
        end

        # Optional. Sleep between tasks.
        Kernel.sleep 60
      rescue Exception => e
        # This gets thrown when we need to get out.
        raise if e.kind_of? SystemExit

        @logger.error "Error in daemon #{self.name} - #{e.class.name}: #{e}"
        @logger.info e.backtrace.join("\n")
        unless zotero.nil?
          zotero.message << e.backtrace.join("\n")
          zotero.save
        end
        # If something bad happened, it usually makes sense to wait for some
        # time, so any external issues can settle.
        Kernel.sleep 60
      end
    end
  end

  def self.stop
    @logger.info "Stopping daemon #{self.name}"
  end
end

ZoteroDirectoryWatcher.daemonize
