# Tab management for the setup area

class Tab

	attr_accessor :id, :label, :url, :subtabs, :advanced

	class << self
		def all
			AmahiHDA::Application.config.tabs
		end
	end

	# controller has the name of the controller (or action in subtabs) this
	#   tab is associated with, e.g. 'users'
	# label is what shows to the user (no localization support yet),
	#   e.g. Users
	# url is what full-url this tab is hooked to, e.g. '/tab/users'
	# parent is the id (controller) of the parent tab
	def initialize(controller, label, url, parent = nil, advanced = false)
		# keep stat with all existing tabs
		self.id = controller
		self.label = label
		self.url = url
		self.subtabs = []
		self.advanced = advanced
		push(self) unless parent
	end

	# add a subtab, with a relative url and the label for it
	# advanced is only reported
	def add(action, label, advanced = false)
		u = (action == 'index') ? self.url : "#{self.url}/#{action}"
		subtabs << Tab.new(action, label, u, self.id, advanced)
	end

	def subtabs?
		subtabs.size != 0
	end

	def basic_subtabs
		subtabs.reject { |s| s.advanced }
	end

	def advanced_subtabs
		subtabs
	end

	# Return the Tab(if exists) with id:contoller. Otherwise creates a new Tab
	def self.find_or_create(controller, label, url)
		tabs = self.find(controller)
		if tabs==nil
		 tabs = Tab.new(controller, label, url)
		end
		tabs
	end

	#Returns Tab with id:controller
	def self.find(controller)
		tabs = nil
		AmahiHDA::Application.config.tabs.each do |tab|
			if tab.id==controller
				tabs = tab
				break
			end
		end
		tabs
	end

	#checks if tab has a subtab with id:controller
	def self.ischild(controller,tab)
		child = false
		if tab.subtabs?
			tab.subtabs.each do |subtab|
				if(subtab.id == controller)
					child = true
					break
				end
			end
		end
		child
	end

	private

	# keep top-level tabs in an app variable, due to complex initialzation issues
	# if we edit files in development, rails will clobber class variables
	def push(element)
		AmahiHDA::Application.config.tabs << element
	end

end
