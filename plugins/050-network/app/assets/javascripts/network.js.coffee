Hosts =
  initialize: ->
    _this = this

    $(document).on "ajax:success", "#new-host-form", (data, results) ->
      unless results["status"] is "ok"
        $('#new-host-form').replaceWith results["content"]
      else
        parent = $("#hosts-table")
        parent.replaceWith results["content"]

    @checkAndShowNoHosts()

    $(document).on "ajax:success", ".btn-delete", ->
      $(this).parents('tr').remove()

      if $('#hosts-table').find('tr').length == 1
        $('#hosts-table table').remove()

      _this.checkAndShowNoHosts()



    $(document).on "ajax:beforeSend", ".btn-delete", ->
      link = $(this)
      spinner = link.parents().children(".spinner")
      spinner.show "fast"
      link.hide()

    $(document).on "ajax:beforeSend", ".create-form", ->
      form = $(this)
      spinner = form.find(".spinner")
      spinner.show "fast"
      form.find("button").hide()

    net = $('#net-message').text()

    $(document).on 'keyup', '#host_address', ->
      $('#net-message').text $(this).val()

  checkAndShowNoHosts: ->
    if $('#hosts-table').find('table').length == 0
      $('#hosts-table .no-hosts').show()

$ ->
  Hosts.initialize()
