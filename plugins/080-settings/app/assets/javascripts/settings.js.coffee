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

$(document).on 'ajax:beforeSend', '.revoke-app', ->
  button = $(this)
  parent = button.parent()
  spinner = parent.find('.spinner')
  spinner.show()
  button.hide()

$(document).on 'ajax:complete', '.revoke-app', ->
  button = $(this)
  parent = button.parent()
  spinner = parent.find('.spinner')
  spinner.hide()
  button.show()
