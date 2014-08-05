require 'rubygems'
require 'rubydora'

#
# This was written to give a quick/dirty XML datastream utility for Fedora without using
# Active Fedora, which can be slow to retrieve large objects.
#

module Stanford

  class Repository

    #
    # This method initializes the fedora repository and solr instance
    attr_reader :repository
    attr_reader :base

    def initialize(base=nil, username=nil, password=nil)
      base ||= Settings.fedora.uri
      username ||= Settings.fedora.user
      password ||= Settings.fedora.password

      @base = base
      @repository = Rubydora.connect :url => base, :user => username, :password => password
    end

    # get all the PIDs in the repository???
    def initialize_queue
      repository.search('pid~druid*').map { |x| x.pid }
    end

   #
   # This method gets a list of datastream ids for an object from Fedora returns it as an array.
   #

    def get_datastreams( pid )
      repository.find(pid).datastreams.keys
    end


    #
    # This method retrieves a comprehensive list of datastreams for the given object
    # It returns either a Nokogiri XML object or a IOString
    #

    def get_datastream( pid, dsID )
      repository.find(pid).datastreams[dsID].content
    end

    # this method takes  pid, dsID, payload, and mime strings and updates the coresponding fedora datastream with the
    # provided XML
    def update_datastream(pid, dsID, data, mime='application/xml' )
      ds = repository.find(pid).datastreams[dsID]
      ds.content = data
      ds.mimeType = mime
      ds.save
    end
  end
end
