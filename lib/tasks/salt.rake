namespace :salt do
  
  desc "Index items from fedora into solr"
  task :index => :environment do
   
      indexer = Stanford::Indexer.new()
      indexer.process_queue
  
  end
  
  
end
