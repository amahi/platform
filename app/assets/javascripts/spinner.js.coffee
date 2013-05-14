Spinner =
  initialize: ->
    $(document).on "ajax:beforeSend", ".remote-btn", ->
      link = $(this)
      link.prev().show "fast"
      link.hide()

    $(document).on "ajax:beforeSend", ".remote-select, .remote-check, .remove-radio", ->
      $(this).next(".spinner").show()
    $(document).on "ajax:complete", ".remote-select, .remote-check, .remove-radio", ->
      $(this).next(".spinner").hide()

    $(document).on "ajax:beforeSend", ".short-form", ->
      form = $(this)
      form.parent().prev().show "fast"

    $(document).on "ajax:complete", ".short-form", ->
      form = $(this)
      form.parent().prev().hide()

    $(document).on "ajax:beforeSend", ".create-form, .update-form", ->
      form = $(this)
      form.find(".spinner").show "fast"
      form.find("button, input[type=submit]").hide()

    $(document).on "ajax:complete", ".update-form", ->
      form = $(this)
      form.find(".spinner").hide()
      form.find("button, input[type=submit]").show()

$ ->
  Spinner.initialize()
