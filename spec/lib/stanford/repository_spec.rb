require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'fakeweb'

describe Stanford::Repository do
 
  before(:all) do
  
    #initialize_queue
    FakeWeb.register_uri(:get,"http://127.0.0.1:8983/fedora-test/objects?query=pid~druid*&maxResults=50000&format=true&pid=true&title=true&resultFormat=xml" , :body => "<objects><pid>first</pid><pid>another</pid></objects>")  
    #get datastreams
    FakeWeb.register_uri(:get,"http://127.0.0.1:8983/fedora-test/objects/fake:druid/datastreams?format=xml", :body => "<object><datastream dsid='first'/><datastream dsid='another'/></object>")
    # get datastream
    FakeWeb.register_uri(:get,"http://127.0.0.1:8983/fedora-test/objects/fake:druid/datastreams/fakeStream/content", :body => "Some content")
    FakeWeb.register_uri(:put, %r|http://fedoraAdmin:fedoraAdmin@127.0.0.1:8983/fedora-test/objects/fake:druid/datastreams/fakeStream|, :query => "<xml/>")
    FakeWeb.register_uri(:put, %r|http://fedoraAdmin:fedoraAdmin@127.0.0.1:8983/fedora-test/objects/druid:fail/datastreams/fakeStream|, :query => "<xml/>",  :body => "Unauthorized", :status => ["401", "Unauthorized"])
    
  end
  
  
  before(:each) do
    @repo = Stanford::Repository.new()
  end
  
  it "should get a list of pids from fedora" do
    @repo.initialize_queue.should == ["first", "another"]
  end
  
  it "should get a list of datastream for an object from fedora" do
     @repo.get_datastreams("fake:druid").should == ["first", "another"]
      @repo.get_datastreams("bs:druid").should be_nil
  end
  
  it "should get the datastream content from an object based on the dsid from fedora" do
    @repo.get_datastream("fake:druid", "fakeStream").should == "Some content"
    @repo.get_datastream("bs:druid", "bsStream").should be_nil
  end
  
  it "#update_datastream" do
    @repo.update_datastream("fake:druid", "fakeStream", "<xml/>").should ==  Net::HTTPSuccess
  end
  
  
  it "should give an error if there's a problem" do
    @repo.update_datastream("druid:fail", "fakeStream", "<xml/>" ).message.should == "401 \"Unauthorized\""
  end
  
end