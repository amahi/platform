module ServerHelper
	# status - "stopped" or "running"
	def server_status(status)
		theme_image_tag("server/#{status}", :title => t(status), :alt => t(status)) + "&nbsp;&nbsp;&nbsp;" + t(status)
	end
end
