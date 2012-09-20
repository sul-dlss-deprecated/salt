require 'rspec/core/rake_task'
require 'jettywrapper'

JETTY_HOME = File.expand_path(File.dirname(__FILE__) + '/../../jetty')
SOLR_HOME = File.expand_path(JETTY_HOME + '/solr')
# SOLR_DATA_DIR = File.expand_path(SOLR_HOME + '/data')
FEDORA_HOME = File.expand_path(JETTY_HOME + '/fedora')

JETTY_PARAMS = {
  # :jetty_home => JETTY_HOME,
  # :jetty_port => 8983,
  # :solr_home => SOLR_HOME,
  # :fedora_home => FEDORA_HOME,
  # :java_opts => "-XX:+CMSPermGenSweepingEnabled -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=128m -Xmx256m",
  # :java_opts => "-Dsolr.data.dir=#{SOLR_DATA_DIR}",
  :startup_wait => 120
}

desc "Continuous integration build"
task :ci do 
  jetty_params = Jettywrapper.load_config.merge(JETTY_PARAMS)
  error = Jettywrapper.wrap(jetty_params) do  
    Rake::Task["spec:rcov"].invoke
  end
  raise "test failures: #{error}" if error
  # Rake::Task["doc"].invoke
end


desc "Start jetty"
task :start do
  puts "starting je"
  jetty_params = Jettywrapper.load_config.merge(JETTY_PARAMS)
  Jettywrapper.start(jetty_params)
  puts "jetty started at PID #{Jettywrapper.pid(JETTY_PARAMS)}"
end
  
desc "stop jetty"
task :stop do
  Jettywrapper.stop(JETTY_PARAMS)
  puts "jetty stopped"
end
