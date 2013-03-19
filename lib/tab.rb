# Tab management for the setup area

class Tab

	# an array holding all existing tabs
	@@tabs = []

	attr_accessor :id, :label, :url, :subtabs

	class << self
		def all
			@@tabs
		end
	end

	def initialize(id, label, url, parent = nil)
		self.id = id
		self.label = label
		self.url = url
		self.subtabs = []
		# a little hacky, but only keep top-level tabs in @@tabs
		if parent
			self.id = parent
		else
			@@tabs << self
		end
	end

	# add a subtab, with a relative url and the label for it
	def add(url, label)
		u = url.blank? ? self.url : "#{self.url}/#{url}"
		s = Tab.new(nil, label, u, id)
		subtabs << s
	end
end
