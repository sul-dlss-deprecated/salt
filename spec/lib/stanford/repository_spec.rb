require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Stanford::Repository do

  before(:each) do
    @repo = Stanford::Repository.new
  end

  it "should get a list of pids from fedora" do
    expect(@repo.repository).to receive(:search).with('pid~druid*').and_return([double(:pid => 'first'), double(:pid => 'another')])
    expect(@repo.initialize_queue).to include("first", "another")
  end

  it "should get a list of datastream for an object from fedora" do
    expect(@repo.repository).to receive(:find).with('fake:druid').and_return(double(:datastreams => {'first' => nil, 'another' => nil}))
    expect(@repo.get_datastreams("fake:druid")).to include("first", "another")
  end

  it "should get the datastream content from an object based on the dsid from fedora" do
    obj = double()
    ds = double(:content => 'Some content')
    expect(obj).to receive(:datastreams).and_return('fakeStream' => ds)
    expect(@repo.repository).to receive(:find).with('fake:druid').and_return(obj)
    expect(@repo.get_datastream("fake:druid", "fakeStream")).to eq("Some content")
  end

  it "#update_datastream" do

    ds = double()
    expect(ds).to receive(:content=).with('<xml/>')
    expect(ds).to receive(:mimeType=)
    expect(ds).to receive(:save)
    obj = double(:datastreams => { 'fakeStream' => ds})
    expect(@repo.repository).to receive(:find).with('fake:druid').and_return(obj)

    @repo.update_datastream("fake:druid", "fakeStream", "<xml/>")
  end

end