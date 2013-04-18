# class to load sample data

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
