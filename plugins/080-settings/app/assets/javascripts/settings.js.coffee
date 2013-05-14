$(document).ready ->
	$(".preftab").on "ajax:success", "#locale", ->
		# reload the page because the whole language has changed
		window.location.reload(true)
