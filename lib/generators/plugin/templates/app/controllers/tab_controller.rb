class TabController < ApplicationController
	before_filter :admin_required
	before_filter :no_subtabs

	layout 'setup_area'

	def index
		# do your thing here
	end

  def tester

  end
end
