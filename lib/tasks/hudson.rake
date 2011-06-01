require 'jettywrapper'
desc "Hudson build"
task :hudson do
  if (ENV['RAILS_ENV'] == "test")
    jetty_params = { 
      :jetty_home => File.expand_path(File.dirname(__FILE__) + '/../../jetty'), 
      :quiet => false, 
      :jetty_port => 8983, 
      :solr_home => File.expand_path(File.dirname(__FILE__) + '/../../jetty/solr'),
      :fedora_home => File.expand_path(File.dirname(__FILE__) + '/../../jetty/fedora/default'),
      :startup_wait => 30
      }
    Rake::Task["db:drop"].invoke
    Rake::Task["db:migrate"].invoke
    error = Jettywrapper.wrap(jetty_params) do  
         Rake::Task["salt:index"].invoke
          Rake::Task["rcov:all"].invoke
    end
    raise "test failures: #{error}" if error
  else
    system("rake hudson RAILS_ENV=test")
    fail unless $?.success?
  end
end

