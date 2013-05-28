#
# Remote Radios
#
# options
# selector - css selector for radios
# custom callbacks:
#   beforeSend(RemoteRadio, radio)
#   success(RemoteRadio, radio)
#   complete(RemoteRadio, radio)
# spinnerParentSelector - where should search for .spinner
#
# this will run within a closure wrapper, so, to expose it as a global variable, we attach it to the window object
#
window.RemoteRadio =
  initialize: (options) ->
    _this = this
    options = options or {}
    $(document).on "click", options["selector"], ->
      options["beforeSend"] = options["beforeSend"] ? ->
      options["success"] = options["success"] ? ->
      options["complete"] = options["complete"] ? ->
      options["spinnerParentSelector"] = options["spinnerParentSelector"] ? "p:first"
      options["parentSelector"] = options["parentSelector"] ? false
      radio = $(this)
      radio.blur()
      if typeof (radio.data("confirm")) is "undefined"
        run_request = true
      else
        run_request = confirm(radio.data("confirm"))
      if run_request and typeof (radio.data("request")) is "undefined"
        request_data = {}
        request_data[radio.attr('name')] = radio.val()
        $.ajax
          beforeSend: ->
            radio.data "request", true
            _this.toggle_spinner options["spinnerParentSelector"], radio
            options["beforeSend"] _this, radio

          type: "PUT"
          data: request_data
          url: _this.url(radio)
          success: (data) ->
            if data["status"] is "ok"
              options["success"] _this, radio, data
              radio.prop "checked", not radio.prop("checked")
            radio.prop "checked", data["force"] unless typeof (data["force"]) is "undefined"

          complete: ->
            try
              _this.toggle_spinner options["spinnerParentSelector"], radio
              options["complete"] _this, radio
              _this.highlight_parent options["parentSelector"], radio if options["parentSelector"]
              radio.removeData "request"
      false

  url: (element) ->
    $(element).data "url"

  toggle_spinner: (spinnerParentSelector, element) ->
    $(element).parents(spinnerParentSelector).find(".spinner:first").toggle()

  highlight_parent: (parentSelector, element) ->
    $(element).parents(parentSelector).effect "highlight"
