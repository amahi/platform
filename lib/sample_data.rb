# class to load sample data
class SampleData
	ROOT = "#{Rails.root}/db/sample-data/%s.yml.gz"

	class << self
		def load(filename)
			file = ROOT % filename
			YAML.load(Zlib::GzipReader.new(StringIO.new(File.read file)).read)
		end
	end
end
