class DisksController < ApplicationController
	before_filter :admin_required

	def index
		@page_title = t('disks')
		unless development?
			@disks = DiskUtils.stats
		else
			# NOTE: this is to get sample fake data in development
			@disks = SampleData.load('disks')
		end
	end

	def mounts
		@page_title =t('disks')
		unless development?
			@mounts = DiskUtils.mounts
		else
			# NOTE: this is to get sample fake data in development
			@mounts = SampleData.load('mounts')
		end
	end
end
