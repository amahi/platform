# SampleData class to load sample data useful in covering many real-life cases in development
# like hard drives temperature, disk size, etc., e.g. if developing on a system like mac os x
#
# Here is how to create fake data, say for Server datastructures
#
# on a real system with real data:
#
#   bash$ rails c
#   :001 > s = Server.all
#   => [#<Server ...>]
#   :002 > open("servers.yml", 'w') {|f| f.write s.to_yaml}
#
# This will save a file called servers.yml. You can edit as necessary to cover corner cases.
# Then do this:
#
#   gzip servers.yml
#   mv servers.yml.gz db/sample-data/
#
# after a rails restart, you can then load the data in some controller or the console with
#
#   @servers = SampleData.load('servers')
#
# In this case, servers is a Rails model, so we need to require 'server' at the top of this file,
# even though it creates extra load/dependencies/bloat to the app. FIXME: load only in development?
#

# require the server model here because we have some Server class data being loaded
require 'server'

class SampleData
	ROOT = "#{Rails.root}/db/sample-data/%s.yml.gz"

	class << self
		def load(filename)
			file = ROOT % filename
			YAML.load(Zlib::GzipReader.new(StringIO.new(File.read file)).read)
		end
	end
end
