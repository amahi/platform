Apps =
	initialize: ->
		_this = this

		$(document).on "ajax:beforeSend", ".install-app-in-background", ->
				$(".install-button").hide()
				_this.toggle_spinner this
				$('.app').each ->
					$(this).find('.install-app-in-background').addClass('inactive')

		$(document).on "ajax:beforeSend", ".uninstall-app-in-background", ->
				_this.toggle_spinner this
				$('.app').each ->
					$(this).find('.install-app-in-background').addClass('inactive')
					$(this).find('.install-button').addClass('inactive')

		$(document).on "ajax:success", ".install-app-in-background, .uninstall-app-in-background", (data, results) ->
				_this.update_progress results["identifier"], results["content"]
				_this.trace_progress results["identifier"]

		RemoteCheckbox.initialize
			selector: ".in_dashboard_checkbox"
			parentSelector: "span:first"

		if document.getElementsByClassName('app-installing')[0]
  			element = document.getElementsByClassName('installation-status')[0]
  			finder = element.classList[1].substr(9)
  			_this.trace_global_progress(finder)

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
		@app(finder).find ".progress-status:first"

	update_progress: (finder, content) ->
		@progress(finder).html content

	update_progress_bar: (finder, progress) ->
		if progress >=0 and progress <= 100
			message = @app(finder).get(0).querySelector(".message")
			if message
				message.style.display = "none"

			progress_bar_div = @app(finder).get(0).querySelector(".progress-bar-div")
			progress_bar = progress_bar_div.querySelector(".progress-bar")

			progress_bar_div.style.display = "inline-block"
			progress_bar.innerHTML = progress + "%"
			progress_bar.style.width = progress+"%"

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
		$('.app').each ->
			$(".install-button").show()

	show_uninstall_button: (finder) ->
		@progress(finder).get(0).querySelector(".install-button").style.display = "inline-block"

		progress_bar_div = @app(finder).get(0).querySelector(".progress-bar-div")
		progress_bar_div.style.display = "none"

		# progress_bar = progress_bar_div.querySelector(".progress-bar")

		@app(finder).get(0).querySelector(".spinner").style.display = "none"
		@app(finder).get(0).querySelector(".app-flash-notice").style.display = "none"

		uninstall_progress = @app(finder).get(0).querySelector(".uninstall_progress")
		uninstall_progress.innerHTML = "Some error occurred during uninstallation."
		uninstall_progress.style.display = "inline-block"

	# case when another app is getting installed - for installed subtab in apps
	show_error_message_installed_tab: (finder, content) ->
		message = @progress(finder).get(0).querySelector(".uninstall_progress")
		message.innerHTML = content

	# case when another app is getting installed - for available subtab in apps
	show_error_message_available_tab: (finder, content) ->
		message = @app(finder).get(0).querySelector(".message")
		message.style.display = "inline-block"
		message.innerHTML = content
		@app(finder).get(0).querySelector(".spinner").style.display = "none"

	global_update_progress:(progress) ->
		element = document.getElementsByClassName('global-progress')[0]
		element.style.width = "#{progress}%"
		element.innerHTML = "#{progress}%"

	wait_and_hide_global_progress:() ->
		setTimeout (->
			element = document.getElementsByClassName('app-installing')[0]
			element.style.display = "none"
			return
		), 2000

	hide_global_progress:() ->
		element = document.getElementsByClassName('app-installing')[0]
		element.style.display = "none"

	trace_progress: (finder) ->
		_this = this
		$.ajax
			url: _this.app(finder).data("progressPath")
			success: (data) ->
				progress = data["progress"]
				timeout_t = 0

				if data["type"].indexOf("uninstall") != -1
					progress = 100 - progress
					if progress == 0
						timeout_t = 2000
				else
					if progress == 100
						timeout_t = 2000

				_this.update_progress_bar finder, progress
				_this.update_progress_message finder, data["content"]

				if progress == 950
					$('.app').each ->
						$(this).find('.install-app-in-background').removeClass('inactive')
					_this.show_error_message_available_tab finder, data["content"]

				else if data["app_content"]
					# 2 seconds wait so that progress bar completes to 100%
					setTimeout (->
					    _this.update_installed_app finder, data["app_content"]
					    $('.app').each ->
					      $(this).find('.install-app-in-background').removeClass('inactive')
					      $(this).find('.install-button').removeClass('inactive')
					    return
					), timeout_t

				else if data["uninstalled"]
					setTimeout (->
						$('.app').each ->
					      $(this).find('.install-app-in-background').removeClass('inactive')
					      $(this).find('.install-button').removeClass('inactive')
						_this.update_uninstalled_app finder
						return
					), 2000

				else if progress == -899 # 100-999
					# this check is for uninstall only, install 999 status handled in if-block
					setTimeout (->
						$('.app').each ->
							$(this).find('.install-app-in-background').removeClass('inactive')
							$(this).find('.install-button').removeClass('inactive')
						_this.show_uninstall_button finder
						return
					), 2000

				else if progress == -850 # 100-950
					$('.app').each ->
						$(this).find('.install-button').removeClass('inactive')
					_this.show_uninstall_button finder
					_this.show_error_message_installed_tab finder, data["content"]

				else
					setTimeout (-> Apps.trace_progress(finder)), 2000

	trace_global_progress: (finder) ->
		_this = this
		$.ajax
			url: _this.app(finder).data("progressPath")
			success: (data) ->
				progress = data["progress"]

				timeout_t = 0

				if data["type"].indexOf("uninstall") != -1
					progress = 100 - progress
					if progress == 0
						timeout_t = 2000
				else
					if progress == 100
						timeout_t = 2000

				_this.global_update_progress(progress)

				if progress >=0 && progress <=100
					if (progress == 0 && data["type"] == "uninstall") || (progress == 100 && data["type"] == "install")
						_this.wait_and_hide_global_progress()
					else
						setTimeout (-> Apps.trace_global_progress(finder)), 2000
				else
					_this.hide_global_progress()

$(document).ready ->
	Apps.initialize()
