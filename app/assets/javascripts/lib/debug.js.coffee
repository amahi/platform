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

# Debug JS functionality


$(document).on "ajax:success", ".debug-form", (event, results) ->
	if results.status is "ok"
		$('#debug-submit-form').html("<p class='alert alert-info'> Error Log Succesfully Submitted</p>")
	else
		$('#debug-submit-form').html("<p class='alert alert-danger'>Debug report failed. Please do try again later.</p>")