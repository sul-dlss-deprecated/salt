# Load the rails application
require File.expand_path('../application', __FILE__)


Mime::Type.register "image/jpg", :jpg
Mime::Type.register "image/jp2", :jp2
Mime::Type.register "	application/pdf", :pdf

# Initialize the rails application
Salt::Application.initialize!
