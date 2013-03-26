module Disks
	class Engine < ::Rails::Engine
		# NOTE: do not isolate the namespace unless you really really
		# want to adjust all your controllers views, etc., making Amahi's
		# platform hard to reach from here
		# isolate_namespace Disks
	end
end
