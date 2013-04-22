$(document).ready ->
	$(".preftab").on "ajax:beforeSend", "#locale", ->
		$(this).next('.spinner').show()
	$(".preftab").on "ajax:success", "#locale", ->
		# reload the page because the whole language has changed
		window.location.reload(true)

	$(".preftab").on "ajax:beforeSend", "#advanced", ->
		$(this).next('.spinner').show()
	$(".preftab").on "ajax:success", "#advanced", ->
		$(this).next('.spinner').hide()

	$(".preftab").on "ajax:beforeSend", "#guest", ->
		$(this).next('.spinner').show()
	$(".preftab").on "ajax:success", "#guest", ->
		$(this).next('.spinner').hide()
