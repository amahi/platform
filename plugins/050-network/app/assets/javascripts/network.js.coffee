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

    SmartLinks.initialize
      open_selector: ".open-update-gateway-area"
      close_selector: ".close-update-gateway-area"
      onShow: (open_link) ->
        form = open_link.next()
        gateway = open_link.text().split('.').splice(-1)[0]
        open_link.after Templates.run("updateGateway",
          gateway: gateway
        )
        FormHelpers.update_first form, open_link.text()
        FormHelpers.focus_first form
        $('#net-message').text gateway

    $(document).on "ajax:success", ".update-lease-time-form, .update-gateway-form", (data, results) ->
      if results["status"] is "ok"
        form = $(this)
        link = form.prev()
        value = results["data"] || FormHelpers.find_first(form).val()
        link.text value

    $(document).on "ajax:complete", ".update-lease-time-form, .update-gateway-form", ->
      form = $(this)
      link = form.prev()
      form.hide "slow", ->
        form.remove()
        link.show()

    $(document).on 'keyup', '#gateway', ->
      $('#net-message').text $(this).val()

    RemoteSelect.initialize
      selector: "#setting_dns select"
      success: (rr, radio, data) ->
        if radio.val() == "custom"
          $('.dns-ips-area').show()
        else
          $('.dns-ips-area').hide()

    $(document).on "ajax:success", "#update-dns-ips-form", (data, results) ->
      $('#update-dns-ips-form #error_explanation').remove()
      unless results["status"] is "ok"
        $errorMessages = $("<div id='error_explanation'><ul></ul></div>")
        $errorMessages.find('ul').append('<li>Format of DNS IP Primary is wrong</li>') if results["ip_1_saved"] == false
        $errorMessages.find('ul').append('<li>Format of DNS IP Secondary is wrong</li>') if results["ip_2_saved"] == false
        $('#update-dns-ips-form').prepend $errorMessages
      else
        $('#update-dns-ips-form input[type=submit]').attr('disabled', 'disabled')

    $(document).on "keyup", "#dns_ip_1, #dns_ip_2", ->
      $('#update-dns-ips-form input[type=submit]').removeAttr('disabled')


    RemoteCheckbox.initialize
      selector: "#checkbox_setting_dnsmasq_dhcp, #checkbox_setting_dnsmasq_dns"

$ ->
  Hosts.initialize()
  DnsAliases.initialize()
  Settings.initialize()

$(document).ready ->
  $(".lease_click_change").click () ->
    $(this).hide()
    $(".edit_lease_form").show()

  $(".lease-cancel-link").click () ->
    form = $('.edit_lease_form').hide()
    $(".lease_click_change").show()

$(document).on "ajax:success", ".edit_lease_form", (event, results) ->
  element = $(".lease_click_change")
  form = $('.edit_lease_form')
  if results.status is "ok"
    element.html($('#lease_time').val())
    form.hide('slow')
    element.show('slow')

$(document).ready ->
  $(".gateway_click_change").click () ->
    $(this).hide()
    $(".edit_gateway_form").show()
    $('.gateway_messages').show()

  $(".gateway-cancel-link").click () ->
    form = $('.edit_gateway_form').hide()
    $('.gateway_messages').hide()
    $(".gateway_click_change").show()


$(document).on 'keyup', '#gateway_input', ->
  $('.gateway_message_value').text $(this).val()

$(document).on "ajax:success", ".edit_gateway_form", (event, results) ->
  element = $(".gateway_click_change")
  element_child = $('.gateway_value')
  form = $('.edit_gateway_form')
  if results.status is "ok"
    element_child.html($('#gateway_input').val())
    form.hide('slow')
    $('.gateway_messages').hide()
    element.show('slow')

