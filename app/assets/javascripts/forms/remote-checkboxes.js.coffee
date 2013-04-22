#
# Remote Checkboxes
#
# options
#	selector - css selector for checkboxes
#	custom callbacks:
#		beforeSend(RemoteCheckbox, checkbox)
#		success(RemoteCheckbox, checkbox)
#		complete(RemoteCheckbox, checkbox)
#	spinnerParentSelector - where should search for .spinner
#
# this will run within a closure wrapper, so, to expose it as a global variable, we attach it to the window object
#
window.RemoteCheckbox =
	initialize: (options) ->
		_this = this
		options = options or {}
		$(document).on "click", options["selector"], ->
			empty = ->

			options["beforeSend"] = (if typeof (options["beforeSend"]) is "undefined" then empty else options["beforeSend"])
			options["success"] = (if typeof (options["success"]) is "undefined" then empty else options["success"])
			options["complete"] = (if typeof (options["complete"]) is "undefined" then empty else options["complete"])
			options["spinnerParentSelector"] = (if typeof (options["spinnerParentSelector"]) is "undefined" then "span:first" else options["spinnerParentSelector"])
			options["parentSelector"] = (if typeof (options["parentSelector"]) is "undefined" then false else options["parentSelector"])
			checkbox = $(this)
			checkbox.blur()
			if typeof (checkbox.data("confirm")) is "undefined"
				run_request = true
			else
				run_request = confirm(checkbox.data("confirm"))
			if run_request and typeof (checkbox.data("request")) is "undefined"
				$.ajax
					beforeSend: ->
						checkbox.data "request", true
						_this.toggle_spinner options["spinnerParentSelector"], checkbox
						options["beforeSend"] _this, checkbox

					type: "PUT"
					url: _this.url(checkbox)
					success: (data) ->
						if data["status"] is "ok"
							options["success"] _this, checkbox, data
							checkbox.prop "checked", not checkbox.prop("checked")
						checkbox.prop "checked", data["force"]	unless typeof (data["force"]) is "undefined"

					complete: ->
						try
							_this.toggle_spinner options["spinnerParentSelector"], checkbox
							options["complete"] _this, checkbox
							_this.highlight_parent options["parentSelector"], checkbox	if options["parentSelector"]
							checkbox.removeData "request"
			false

	url: (element) ->
		$(element).data "url"

	toggle_spinner: (spinnerParentSelector, element) ->
		$(element).parents(spinnerParentSelector).find(".spinner:first").toggle()

	highlight_parent: (parentSelector, element) ->
		$(element).parents(parentSelector).effect "highlight"
