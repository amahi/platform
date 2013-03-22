$(document).ready ->
	$('#locale').live
		"ajax:beforeSend": () ->
			$(this).next('.spinner').show()
		"ajax:success": () ->
			window.location.reload(true)

	$('#advanced').live
		"ajax:beforeSend": () ->
			$(this).next('.spinner').show()
		"ajax:success": () ->
			$(this).next('.spinner').hide()

	$('#guest').live
		"ajax:beforeSend": () ->
			$(this).next('.spinner').show()
		"ajax:success": () ->
			$(this).next('.spinner').hide()
		
