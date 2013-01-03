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

module UsersHelper

  def user_icon_class(user)
    user_icon = ""
    user_icon = "user_admin" if user.admin
    user_icon = "user_warn" if user.needs_auth?
    user_icon
  end

  def confirm_user_destroy_message(login)
    [t('are_you_sure_user', :user => login),
     t('this_users_files_deleted'), "", t('there_is_no_undo'), ""].join("\n").html_safe
  end

  def user_formatted_date(date)
    date = date.localtime
    "#{date.to_formatted_s(:short)} (#{time_ago_in_words(date)})"
  rescue
    '-'
  end

end
