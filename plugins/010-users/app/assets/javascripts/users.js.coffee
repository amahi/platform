# delete a user
$(document).on 'ajax:beforeSend', '.btn-delete', ->
	$(this).parents('.settings-actions').find('.spinner').show()

$(document).on 'ajax:success', '.btn-delete', (event, results) ->
	user = $("#whole_user_" + results['id'])
	user.hide 'slow', ->
		user.remove()

# update user password
$(document).on 'ajax:success', '.update-password', (event, results) ->
	msg = $(this).nextAll(".messages:first")
	msg.text results["message"]
	setTimeout (-> msg.text ""), 8000

$(document).on 'ajax:complete', '.update-password', ->
	$(this).find(".spinner").hide()
	$(this).find(".password-edit").hide()
	$(this).find("input[type=password]").val ""

$(document).on 'ajax:beforeSend', '.update-password', ->
	$(this).find(".spinner").show "fast"

# new user
$(document).on 'ajax:success', '#new-user-form', (event, results) ->
	form = $(this)
	unless results['status'] is 'ok'
		form.replaceWith results["content"]
	else
		$('#users-table').parent().html results["content"]
		form.find("input[type=text], input[type=password]").val ""
	form

# management of the public key area
$(document).on 'ajax:success', '.update-pubkey', (event, results) ->
	form = $(this)
	spinner = form.parent().parent().find(".spinner")
	spinner.hide()
	if results["status"] is "ok"
		image = form.parent().parent().children(".ok")
	else
		image = form.parent().parent().children(".error")
	image.show()
	setTimeout (-> image.hide "slow"), 3000

$(document).on 'ajax:beforeSend', '.update-pubkey', ->
	form = $(this)
	spinner = form.parent().parent().find(".spinner")
	spinner.show()
	form.parent().hide('slow')

# username editing - FIXME - not working from here on to the bottom
$(document).on 'ajax:success', '.username-form', (event, results) ->
	if results["status"] is "ok"
		form = $(this)
		link = form.prev()
		value = FormHelpers.find_first(form).val()
		link.text value

$(document).on 'ajax:complete', '.username-form', (event, results) ->
	form = $(this)
	link = form.prev()
	form.hide "slow", ->
		form.remove()
		link.show()


Users =
	parse_id: (html_id) ->
		html_id.split("_").last()

	user: (finder) ->
		(if typeof (finder) is "string" then @user_by_id(finder) else @user_by_element(finder))

	user_by_element: (element) ->
		$(element).parents ".user:first"

	user_by_id: (id) ->
		$ "#whole_user_" + id

	delete_area_toggle: (element) ->
		@user(element).find(".delete:first").toggle()

	form: (element) ->
		(if element then $(element).parents("form:first") else $("#new-user-form"))

	initialize: () ->
		_this = this
		SmartLinks.initialize
			open_selector: ".open-username-edit"
			close_selector: ".close-username-edit"
			onShow: (open_link) ->
				user = _this.user(open_link)
				user_id = _this.parse_id(user.attr("id"))
				open_link.after Templates.run("updateUsername", user_id: user_id)
				form = open_link.next()
				FormHelpers.update_first form, open_link.text()
				FormHelpers.focus_first form
		RemoteCheckbox.initialize
			selector: ".user_admin_checkbox"
			parentSelector: "span:first"
			success: (rc, checkbox) ->
				_this.user(checkbox).find(".user_icons:first").toggleClass "user_admin"
				_this.delete_area_toggle checkbox

$(document).ready ->
	Users.initialize()
