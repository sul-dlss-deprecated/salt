# This will guess the User class
Factory.define :user do |u|
  u.email "jdoe@stanford.edu"
  u.password "foobar"
  u.approved true
end


Factory.define :admin, :class => User do |u|
  u.email "mrbossman@stanford.edu"
  u.password "foobar"
  u.approved true
  u.admin true
end

Factory.define :zotero_ingest do |z|
    z.ingest_start Time.now
    z.message  "MyText"
    z.filename  "Filename"
end


