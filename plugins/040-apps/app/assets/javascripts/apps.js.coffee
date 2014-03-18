Apps =
	initialize: ->
		_this = this

		$(document).on "ajax:beforeSend", ".install-app-in-background, .uninstall-app-in-background", ->
			$(".install-button").hide()
			_this.toggle_spinner this
			$('.app').each -> 
				$(this).find('.install-app-in-background').addClass('inactive')
		
		$(document).on "ajax:success", ".install-app-in-background, .uninstall-app-in-background", (data, results) ->
				_this.update_progress results["identifier"], results["content"]
				_this.trace_progress results["identifier"]
				$('.app').each -> 
				$(this).find('.install-app-in-background').removeClass('inactive')

		RemoteCheckbox.initialize
			selector: ".in_dashboard_checkbox"
			parentSelector: "span:first"

	app: (finder) ->
		(if typeof (finder) is "string" then @app_by_identifier(finder) else @app_by_element(finder))

	app_by_element: (element) ->
		$(element).parents ".app:first"

	app_by_identifier: (identifier) ->
		$ "#app_whole_" + identifier

	toggle_spinner: (finder) ->
		app = @app(finder)
		app.find(".spinner").toggle()

	progress: (finder) ->
		@app(finder).find ".progress:first"

	update_progress: (finder, content) ->
		@progress(finder).html content

	progress_message: (finder) ->
		@app(finder).find ".install_progress"

	update_progress_message: (finder, content) ->
		@progress_message(finder).html content

	show_app_flash_notice: (finder) ->
		app = @app(finder)
		notice = app.find(".app-flash-notice")
		notice.show()

	update_installed_app: (finder, content) ->
		_this = this
		app = @app(finder)
		app.replaceWith content
		_this.show_app_flash_notice finder
		$(".install-button").show()

	update_uninstalled_app: (finder) ->
		@app(finder).remove()
		$(".install-button").show()

	trace_progress: (finder) ->
		_this = this
		$.ajax
			url: _this.app(finder).data("progressPath")
			success: (data) ->
				_this.update_progress_message finder, data["content"]
				if data["app_content"]
					_this.update_installed_app finder, data["app_content"]
				else if data["uninstalled"]
					_this.update_uninstalled_app finder
				else
					setTimeout (-> Apps.trace_progress(finder)), 2000


$(document).ready ->
	Apps.initialize()

