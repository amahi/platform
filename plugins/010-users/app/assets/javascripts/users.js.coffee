# delete a user
$(document).on "ajax:success", ".btn-delete", (event, results) ->
  user = $("#whole_user_" + results["id"])
  unless results["status"] is "ok"
    alert results["status"]
    $(this).parent().find(".spinner").hide()
    $(this).show()
  else
    user.hide "slow", ->
      user.remove()
#update fullname
$(document).ready ->
	$(".name_click_change").click () ->
	  $(this).hide()
	  $(this).parent().find(".edit_name_form").show()

	$(".name_cancel_link").click () ->
	  id = $(this).data("id")
	  element = "#whole_user_"+id
	  form = $(element).find('.edit_name_form')
	  form.hide()
	  $(element).find(".name_click_change").show()


$(document).on "ajax:success", ".edit_name_form", (event, results) ->
  element = "#whole_user_"+results.id
  msg = $(element).find(".messages")
  msg.html results.message
  setTimeout (-> msg.html ""), 8000
  id = results["id"]
  element = $("#text_user_" + results["id"])
  $(element).val results["name"]
  if results.status is "ok"
    col_element = $("#whole_user_" + results["id"])
    $(this).hide('slow')
    elem = $(this).closest('td').find(".name_click_change")
    elem.html results["name"]
    elem.show()
    $(col_element).find(".users-col2").html results["name"]



# update user password
$(document).on 'ajax:success', '.update-password', (event, results) ->
	msg = $(this).find(".messages:first")
	msg.html results["message"]
	setTimeout (-> msg.html ""), 8000
	if results.status is 'ok'
		$(this).find("input[type=password]").val ""
		$(this).find(".password-edit").hide("slow")

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
	if results["status"] is "ok"
		image = form.parent().parent().children(".ok")
	else
		image = form.parent().parent().children(".error")
	image.show()
	setTimeout (-> image.hide "slow"), 3000

$(document).on 'ajax:beforeSend', '.update-pubkey', ->
	form = $(this)
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

	toggle_delete_area: (element) ->
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
				user_id = _this.parse_id(user.prop("id"))
				open_link.after Templates.run("updateUsername", user_id: user_id)
				form = open_link.next()
				FormHelpers.update_first form, open_link.text()
				FormHelpers.focus_first form
		RemoteCheckbox.initialize
			selector: ".user_admin_checkbox"
			parentSelector: "span:first"
			success: (rc, checkbox) ->
				_this.user(checkbox).find(".user_icons:first").toggleClass "user_admin"
				_this.toggle_delete_area checkbox

$(document).ready ->
	Users.initialize()
