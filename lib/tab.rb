# Tab management for the setup area

class Tab

	attr_accessor :id, :label, :url, :subtabs

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
	def initialize(controller, label, url, parent = nil)
		# keep stat with all existing tabs
		self.id = controller
		self.label = label
		self.url = url
		self.subtabs = []
		push(self) unless parent
	end

	# add a subtab, with a relative url and the label for it
	def add(action, label)
		u = (action == 'index') ? "../"+self.id : "#{self.url}/#{action}"
		subtabs << Tab.new(action, label, u, self.id)
	end

	def subtabs?
		subtabs.size != 0
	end

	private

	# keep top-level tabs in an app variable, due to complex initialzation issues
	# if we edit files in development, rails will clobber class variables
	def push(element)
		AmahiHDA::Application.config.tabs << element
	end

end
