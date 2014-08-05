namespace :salt do
  
  desc "Index items from fedora into solr. Uses a list file for the pids to be index found at RAILS_ROOT/doc/pids.txt."
  task :index => :environment do    
    indexer = Stanford::Indexer.new(Stanford::Repository.new.initialize_queue)
    indexer.process_queue
  end
end
