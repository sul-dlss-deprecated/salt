  desc "Hudson build"
  task :hudson do
    
      Rake::Task["hydra:jetty:start"].invoke
        Rake::Task["salt:index"].invoke
        Rake::Task["rcov:all"].invoke
        Rake::Task["hydra:jetty:stop"].invoke
  end
