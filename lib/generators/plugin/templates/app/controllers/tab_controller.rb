class TabController < ApplicationController
	before_filter :admin_required
	before_filter :no_subtabs

	def index
		# do your thing here
	end
end
