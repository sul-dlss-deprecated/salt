namespace :salt do
  
  desc "Index items from fedora into solr. Uses a list file for the pids to be index found at RAILS_ROOT/doc/pids.txt."
  task :index => :environment do
      
      if File.exists?(File.join(File.dirname(__FILE__) , '/../../doc/pids.txt'))
        pids = []
        File.open(File.join(File.dirname(__FILE__) , '/../../doc/pids.txt')).each_line { |p| pids << p.chomp }
        indexer = Stanford::Indexer.new(pids)
        indexer.process_queue
      else
        p "No list file found at RAILS_ROOT/doc/pids.txt"
      end
  
  end
  
  
end
