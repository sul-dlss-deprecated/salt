require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Stanford::Repository do

  before(:each) do
    @repo = Stanford::Repository.new
  end

  it "should get a list of pids from fedora" do
    @repo.repository.expects(:search).with('pid~druid*').returns([mock(:pid => 'first'), mock(:pid => 'another')])
    @repo.initialize_queue.should include("first", "another")
  end

  it "should get a list of datastream for an object from fedora" do
    @repo.repository.expects(:find).with('fake:druid').returns(mock(:datastreams => {'first' => nil, 'another' => nil}))
    @repo.get_datastreams("fake:druid").should include("first", "another")
  end

  it "should get the datastream content from an object based on the dsid from fedora" do
    obj = mock()
    ds = mock(:content => 'Some content')
    obj.expects(:datastreams).returns('fakeStream' => ds)
    @repo.repository.expects(:find).with('fake:druid').returns(obj)
    @repo.get_datastream("fake:druid", "fakeStream").should == "Some content"
  end

  it "#update_datastream" do

    ds = mock()
    ds.expects(:content=).with('<xml/>')
    ds.expects(:mimeType=)
    ds.expects(:save)
    obj = mock(:datastreams => { 'fakeStream' => ds})
    @repo.repository.expects(:find).with('fake:druid').returns(obj)

    @repo.update_datastream("fake:druid", "fakeStream", "<xml/>")
  end

end