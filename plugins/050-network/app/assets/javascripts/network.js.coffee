Network =
  initialize: ->
    _this = this

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

Hosts =
  initialize: ->
    _this = this

    $(document).on "ajax:success", "#new-host-form", (data, results) ->
      unless results["status"] is "ok"
        $('#new-host-form').replaceWith results["content"]
      else
        parent = $("#hosts-table")
        parent.replaceWith results["content"]

    @checkAndShowEmptyHint()

    $(document).on "ajax:success", ".btn-delete", ->
      $(this).parents('div.entry').remove()

      if $('#hosts-table').find('.entry').length == 0
        $('#hosts-table table').remove()

      _this.checkAndShowEmptyHint()

    net = $('#net-message').text()

    $(document).on 'keyup', '#host_address', ->
      $('#net-message').text $(this).val()

  checkAndShowEmptyHint: ->
    if $('#hosts-table').find('table').length == 0
      $('#hosts-table .empty-hint').show()

DnsAliases =
  initialize: ->
    _this = this

    $(document).on "ajax:success", "#new-dns-alias-form", (data, results) ->
      unless results["status"] is "ok"
        $('#new-dns-alias-form').replaceWith results["content"]
      else
        parent = $("#dns-aliases-table")
        parent.replaceWith results["content"]

    @checkAndShowEmptyHint()

    $(document).on "ajax:success", ".btn-delete", ->
      $(this).parents('tr').remove()

      if $('#dns-aliases-table').find('tr').length == 1
        $('#dns-aliases-table table').remove()

      _this.checkAndShowEmptyHint()

    net = $('#net-message').text()

    $(document).on 'keyup', '#dns_alias_address', ->
      $('#net-message').text $(this).val()

  checkAndShowEmptyHint: ->
    if $('#dns-aliases-table').find('table').length == 0
      $('#dns-aliases-table .empty-hint').show()

$ ->
  Network.initialize()
  Hosts.initialize()
  DnsAliases.initialize()
