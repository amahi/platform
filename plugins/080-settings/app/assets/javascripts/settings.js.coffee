Servers =
  initialize: ->
    $(document).on 'ajax:success', '.btn-refresh, .btn-start, .btn-stop, .btn-restart', (data, results) ->
      link = $(this)
      content = $(results["content"])
      content.find('.settings-stretcher').show()
      link.parents('.server').replaceWith content

    RemoteCheckbox.initialize
      selector: ".server_monitored_checkbox, .server_start_at_boot_checkbox"
      success: (rc, checkbox, data) ->
        content = $(data["content"])
        content.find('.settings-stretcher').show()
        $(checkbox).parents('.server').replaceWith content

$ ->
  Servers.initialize()

# reload the page with locale change because the whole language has changed
$ ->
    $(".preftab").on "ajax:success", "#locale", ->
       window.location.reload(true)

$(document).on "click", ".remote-check", (event)->
  checkbox = $(this)
  checkbox.prop("checked",!checkbox.prop("checked"))
  true

$(document).on "ajax:complete",".remote-check", ->
      $(this).prop("checked",!$(this).prop("checked"))

$(document).on "ajax:complete",".unlock-uninstall",->
        $('.unlock-uninstall').hide()
$(document).on "ajax:complete",".unlock-install",->
        $('.unlock-install').hide()