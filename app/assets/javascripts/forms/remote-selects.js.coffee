# Remote select implementation
#
# options
#
#	selector - css selector for selects
#
#	custom callbacks:
#	beforeSend(RemoteSelect, select)
#	success(RemoteSelect, select
#	complete(RemoteSelect, select)
#
#	spinnerParentSelector - where should search for .spinner
#
# this will run within a closure wrapper, so, to expose it as a global variable, we attach it to the window object
#		 
window.RemoteSelect =
	initialize: (options) ->
		_this = this
		options = options or {}
		$(document).on "change", options["selector"], ->
			options["beforeSend"] = options["beforeSend"] ? ->
			options["success"] = options["success"] ? ->
			options["complete"] = options["complete"] ? ->
			options["spinnerParentSelector"] = options["spinnerParentSelector"] ? "span:first"
			options["parentSelector"] = options["parentSelector"] ? false
			select = $(this)
			select.blur()
			if typeof (select.data("confirm")) is "undefined"
				run_request = true
			else
				run_request = confirm(select.data("confirm"))
			if run_request and typeof (select.data("request")) is "undefined"
				$.ajax
					beforeSend: ->
						select.data "request", true
						_this.toggle_spinner options["spinnerParentSelector"], select
						options["beforeSend"] _this, select

					type: "PUT"
					url: _this.url(select)
					success: (data) ->
						options["success"] _this, select, data if data["status"] is "ok"

					complete: ->
						try
							_this.toggle_spinner options["spinnerParentSelector"], select
							options["complete"] _this, checkbox
							_this.highlight_parent options["parentSelector"], select if options["parentSelector"]
							select.removeData "request"

			false


	url: (element) ->
		$(element).data "url"

	toggle_spinner: (spinnerParentSelector, element) ->
		$(element).parents(spinnerParentSelector).find(".spinner:first").toggle()

	highlight_parent: (parentSelector, element) ->
		$(element).parents(parentSelector).effect "highlight"
