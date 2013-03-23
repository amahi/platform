module ServersHelper
	# status - "stopped" or "running"
	def server_status(status)
		content_tag('span',
			    content_tag('i', '', class: status).html_safe + t(status),
			    title: t(status), class: "server_status")
	end
end
