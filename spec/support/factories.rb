require 'factory_girl'

FactoryGirl.define do
  # This will guess the User class
  factory :user do |u|
    u.email "jdoe@stanford.edu"
    u.password "foobar"
    u.approved true
  end

  factory :not_approved, :class => User do |u|
    u.email "msnotapproved@stanford.edu"
    u.password "foobar"
    u.approved false
  end

  factory :admin, :class => User do |u|
    u.username "mrbossman"
    u.email "mrbossman@stanford.edu"
    u.password "foobar"
    u.approved true
    u.admin true
  end

  factory :zotero_ingest do |z|
    z.ingest_start Time.now
    z.message  "MyText"
    z.filename  "Filename"
  end

end
