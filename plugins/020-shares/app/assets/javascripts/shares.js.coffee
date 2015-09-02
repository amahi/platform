# Amahi Home Server
# Copyright (C) 2007-2013 Amahi
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License v3
# (29 June 2007), as published in the COPYING file.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# file COPYING for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Amahi
# team at http://www.amahi.org/ under "Contact Us."

# Shares JS functionality

Shares =
	initialize: ->
		_this = this

		# new share
		$(document).on "ajax:success", "#new-share-form", (data, results) ->
			unless results["status"] is "ok"
				_this.form().replaceWith results["content"]
			else
				parent = $("#shares-table")
				parent.replaceWith results["content"]

		$(document).on "blur", "#share_comment", ->
			share_comment = $(this)
			share_path = $("#share_path")
			if share_comment.val() isnt "" and share_path.val() is ""
				share_path.val share_path.data("pre") + share_comment.val()
				FormHelpers.focus share_path

		# deleting a share
		$(document).on "ajax:success", ".btn-delete", ->
			share = _this.share($(this))
			share.remove()
		#update workgroup
		$(document).ready ->
			$(".workgroup_click_change").click () ->
			  $(this).hide()
			  $(this).parent().find(".edit_workgroup_form").show()

			$(".workgroup_cancel_link").click () ->
			  id = $(this).data("id")
			  form = "#div_form_"+id
			  $(form).find('form').hide()
			  $(form).parent().find(".workgroup_click_change").show()

		$(document).on "ajax:success", ".edit_workgroup_form",(event, results) ->
			msg = $(this).parent().parent().find(".messages")
			msg.html results.message
			setTimeout (-> msg.html ""), 8000
			if results.status is 'ok'
				$(this).hide('slow')
				$(this).parent().parent().find(".workgroup_click_change").val results.name
				$(this).parent().parent().find(".workgroup_click_change").show()

		RemoteCheckbox.initialize
			selector: ".share_visible_checkbox"
			parentSelector: "span:first"

		RemoteCheckbox.initialize
			selector: ".share_everyone_checkbox, .share_access_checkbox, .share_guest_access_checkbox"
			parentSelector: "span:first"
			spinnerParentSelector: ".access"
			success: (rc, checkbox, data) ->
				_this.update_access_area checkbox, data["content"]

		RemoteCheckbox.initialize
			selector: ".share_readonly_checkbox, .share_write_checkbox, .share_guest_writeable_checkbox"
			parentSelector: "span:first"
			spinnerParentSelector: ".access"

		# update tags
		SmartLinks.initialize
			open_selector: ".open-update-tags-area"
			close_selector: ".close-update-tags-area"
			onShow: (open_link) ->
				share = _this.share(open_link)
				share_id = _this.parse_id(share.attr("id"))
				open_link.after Templates.run("updateTags",
					share_id: share_id
				)
				form = open_link.next()
				FormHelpers.update_first form, open_link.text()
				FormHelpers.focus_first form

		$(document).on "ajax:success", ".update-tags-form", (data, results) ->
			form = $(this)
			share = _this.share(form)
			share.find(".tags:first").replaceWith results["content"]

		RemoteCheckbox.initialize
			selector: ".share_tags_checkbox"
			parentSelector: "span:first"
			spinnerParentSelector: ".tags"
			success: (rc, checkbox, data) ->
				checkbox = $(checkbox)
				share = _this.share(checkbox)
				share.find(".tags:first").replaceWith data["content"]

		# update path
		SmartLinks.initialize
			open_selector: ".open-update-path-area"
			close_selector: ".close-update-path-area"
			onShow: (open_link) ->
				share = _this.share(open_link)
				share_id = _this.parse_id(share.attr("id"))
				open_link.after Templates.run("updatePath",
					share_id: share_id
				)
				form = open_link.next()
				FormHelpers.update_first form, open_link.text()
				FormHelpers.focus_first form

		$(document).on "ajax:success", ".update-path-form", (data, results) ->
			if results["status"] is "ok"
				form = $(this)
				link = form.prev()
				value = FormHelpers.find_first(form).val()
				link.text value

		$(document).on "ajax:complete", ".update-path-form", ->
				form = $(this)
				link = form.prev()
				form.hide "slow", ->
					form.remove()
					link.show()

		RemoteCheckbox.initialize
			selector: ".disk_pooling_checkbox"
			parentSelector: "span:first"

		RemoteCheckbox.initialize
			selector: ".disk_pool_checkbox"
			parentSelector: "span:first"
			success: (rc, checkbox, data) ->
				checkbox = $(checkbox)
				share = _this.share(checkbox)
				share.find(".disk-pool:first").replaceWith data["content"]

		#update size
		$('.update-size-area').on "ajax:success", (data, results) ->
			$('.size'+results.id).text( results.size )

		# update extras
		SmartLinks.initialize
			open_selector: ".open-update-extras-area"
			close_selector: ".close-update-extras-area"
			onShow: (open_link) ->
				share = _this.share(open_link)
				share_id = _this.parse_id(share.attr("id"))
				open_link.after Templates.run("updateExtras",
					share_id: share_id
				)
				form = open_link.next()
				FormHelpers.update_first form, open_link.text()
				FormHelpers.focus_first form

		$(document).on "ajax:success", ".update-extras-form", (data, results) ->
			if results["status"] is "ok"
				form = $(this)
				link = form.prev()
				text_area = FormHelpers.find_first(form)
				value = $.trim(text_area.val())
				value = (if (value is "") then text_area.attr("placeholder") else value)
				link.text value

		$(document).on "ajax:complete", ".update-extras-form", (data, results) ->
			form = $(this)
			link = form.prev()
			form.hide "slow", ->
				form.remove()
				link.show()

		$(document).on "ajax:success", ".clear-permissions", (data, results) ->
			link = $(this)
			parent = link.parent()
			if results["status"] is "ok"
				parent.html FormHelpers.ok_icon
			else
				parent.html FormHelpers.error_icon


	parse_id: (html_id) ->
		html_id.split("_").last()

	share: (finder) ->
		(if typeof (finder) is "string" then @share_by_id(finder) else @share_by_element(finder))

	share_by_element: (element) ->
		$(element).parents ".share"

	share_by_id: (id) ->
		$ "#whole_share_" + id

	access_area: (element) ->
		@share(element).find ".access:first"

	update_access_area: (element, content) ->
		@access_area(element).html content

	form: (element) ->
		(if element then $(element).parents("form:first") else $("#new-share-form"))

$(document).ready ->
	Shares.initialize()
