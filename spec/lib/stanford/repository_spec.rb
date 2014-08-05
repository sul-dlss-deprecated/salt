require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Stanford::Repository do

  before(:each) do
    @repo = Stanford::Repository.new
  end

  it "should get a list of pids from fedora" do
    @repo.repository.should_receive(:search).with('pid~druid*').and_return([double(:pid => 'first'), double(:pid => 'another')])
    @repo.initialize_queue.should include("first", "another")
  end

  it "should get a list of datastream for an object from fedora" do
    @repo.repository.should_receive(:find).with('fake:druid').and_return(double(:datastreams => {'first' => nil, 'another' => nil}))
    @repo.get_datastreams("fake:druid").should include("first", "another")
  end

  it "should get the datastream content from an object based on the dsid from fedora" do
    obj = double()
    ds = double(:content => 'Some content')
    obj.should_receive(:datastreams).and_return('fakeStream' => ds)
    @repo.repository.should_receive(:find).with('fake:druid').and_return(obj)
    @repo.get_datastream("fake:druid", "fakeStream").should == "Some content"
  end

  it "#update_datastream" do

    ds = double()
    ds.should_receive(:content=).with('<xml/>')
    ds.should_receive(:mimeType=)
    ds.should_receive(:save)
    obj = double(:datastreams => { 'fakeStream' => ds})
    @repo.repository.should_receive(:find).with('fake:druid').and_return(obj)

    @repo.update_datastream("fake:druid", "fakeStream", "<xml/>")
  end

end