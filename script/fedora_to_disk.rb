#!/usr/bin/env ruby
require '../lib/stanford/repository'
require 'FileUtils'

@repo = Stanford::Repository.new('http://salt-prod.stanford.edu:8080/fedora', 'fedoraAdmin', 'ff854848eebeaaeb717293629669116d')

File.open("druid_list.txt").each_line do |line|
  
  line.chomp!
  dir = File.join("/tmp/assets", "#{line.gsub('druid:', '')}")
  FileUtils.mkdir_p(dir)
  print line + "\t"
  dses = @repo.get_datastreams(line)
  dses.each do |ds|
    file = File.open(File.join( dir, ds ), "w")
    file << @repo.get_datastream(line, ds)
    file.close
    print ds + "\t"
  end
  
  print "\n"
  
  
end