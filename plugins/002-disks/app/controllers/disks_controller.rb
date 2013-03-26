class DisksController < ApplicationController
	before_filter :admin_required

	def index
            @page_title = t('disks')
		@disks = DiskUtils.stats
	end

      def mounts
        @page_title =t('disks')
        @mounts = DiskUtils.mounts
      end
end
