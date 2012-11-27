begin
require 'rspec/core/rake_task'
rescue LoadError
  puts "RSpec not found"
end
require 'jettywrapper'
require 'active_fedora'
namespace :salt do

  FIXTURE_PIDS = [
    'druid:bb047vy0535',
    'druid:ff241yc8373',
    'druid:pt839dg9461',
    'druid:rp824rd3381',
    'druid:sf816yk9336',
    'druid:yz604wq6818',
    'druid:zq847yk5675'
  ]

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

  desc "Load fixtures.  Use RAILS_ENV=test to perform on test solr."
  task :load_fixtures => :environment do
    ActiveFedora.init(:fedora_config_path => File.expand_path(File.dirname(__FILE__) + '/../../config/fedora.yml'))
    fixtures_dir = File.expand_path(File.dirname(__FILE__) + '/../../spec/fixtures/fedora_objects')
    Dir.glob("#{fixtures_dir}/*.xml") do |foxml_file|
      begin
        ActiveFedora::FixtureLoader.import_to_fedora(foxml_file)
      rescue => e
        puts e
      end
    end
  end

  desc "Delete fixtures. Use RAILS_ENV=test to perform on test fedora"
  task :delete_fixtures => :environment do
    FIXTURE_PIDS.each { |pid|
      begin
        ENV["pid"] = pid
        Rake::Task['repo:delete'].reenable
        Rake::Task['repo:delete'].invoke
      rescue
      end
  }
  end

  desc "Continuous integration build"
  task :ci do
    Rails.env = 'test'
    jetty_params = Jettywrapper.load_config.merge(JETTY_PARAMS)
    Rake::Task["db:migrate"].invoke
    Rake::Task["salt:jetty_setup"].invoke
    Jettywrapper.wrap(jetty_params) do
      Rake::Task["salt:delete_fixtures"].invoke
      Rake::Task["salt:load_fixtures"].invoke
      Rake::Task["salt:index"].invoke
      Rake::Task["spec:rcov"].invoke
    end
    Rake::Task["doc"].invoke
  end

  desc "Set up jetty"
  task :jetty_setup do
    puts "setting up jetty"
    salt_solr_config = File.expand_path(File.dirname(__FILE__) + '/../../config/solr_config/solrconfig.xml')
    jetty_solr_config_dev = File.expand_path(File.dirname(__FILE__) + '/../../jetty/solr/development-core/conf/solrconfig.xml')
    jetty_solr_config_test = File.expand_path(File.dirname(__FILE__) + '/../../jetty/solr/test-core/conf/solrconfig.xml')
    FileUtils.cp salt_solr_config, jetty_solr_config_dev
    FileUtils.cp salt_solr_config, jetty_solr_config_test
  end

  desc "Start jetty"
  task :start do
    puts "starting jetty"
    jetty_params = Jettywrapper.load_config.merge(JETTY_PARAMS)
    Jettywrapper.start(jetty_params)
    puts "jetty started at PID #{Jettywrapper.pid(JETTY_PARAMS)}"
  end

  desc "stop jetty"
  task :stop do
    Jettywrapper.stop(JETTY_PARAMS)
    puts "jetty stopped"
  end

end
