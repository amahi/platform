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
      $(this).parents('div.entry').remove()

      if $('#dns-aliases-table').find('tr').length == 0
        $('#dns-aliases-table table').remove()

      _this.checkAndShowEmptyHint()

    net = $('#net-message').text()

    $(document).on 'keyup', '#dns_alias_address', ->
      $('#net-message').text $(this).val()

  checkAndShowEmptyHint: ->
    if $('#dns-aliases-table').find('table').length == 0
      $('#dns-aliases-table .empty-hint').show()

Settings =
  initialize: ->
    _this = this

    SmartLinks.initialize
      open_selector: ".open-update-lease-time-area"
      close_selector: ".close-update-lease-time-area"
      onShow: (open_link) ->
        form = open_link.next()
        open_link.after Templates.run("updateLeaseTime",
          lease_time: open_link.text()
        )
        FormHelpers.update_first form, open_link.text()
        FormHelpers.focus_first form

    $(document).on "ajax:beforeSend", "#update-lease-time-form", ->
      $(this).find('.spinner').show()

    $(document).on "ajax:success", ".update-lease-time-form", (data, results) ->
      if results["status"] is "ok"
        form = $(this)
        link = form.prev()
        value = FormHelpers.find_first(form).val()
        link.text value

    $(document).on "ajax:complete", ".update-lease-time-form", ->
      form = $(this)
      link = form.prev()
      form.hide "slow", ->
        form.remove()
        form.find('.spinner').hide()
        link.show()

$ ->
  Network.initialize()
  Hosts.initialize()
  DnsAliases.initialize()
  Settings.initialize()
