# Load the rails application
require File.expand_path('../application', __FILE__)

Mime::Type.register 'image/png', :png
Mime::Type.register "image/jpg", :jpg
Mime::Type.register "image/jp2", :jp2
Mime::Type.register "application/pdf", :pdf
Mime::Type.register "application/x-javascript", :flipbook

# Initialize the rails application
Salt::Application.initialize!
