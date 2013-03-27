class DisksController < ApplicationController
	before_filter :admin_required

	def index
		@page_title = t('disks')
		@disks = DiskUtils.stats
		# NOTE: to get sample fake data, uncomment this:
		#@disks = SampleData.load('disks')
	end

	def mounts
		@page_title =t('disks')
		@mounts = DiskUtils.mounts
		# NOTE: to get sample fake data, uncomment this:
		#@mounts = SampleData.load('mounts')
	end
end
