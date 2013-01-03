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

module AppsHelper

  def short_desc(app)
    desc = app.description ? app.description.gsub(/<[^>]+>/, '') : t('no_description_supplied')
    desc = truncate(strip_tags(desc), :length => 70, :omission => '&nbsp;...') if desc.length > 70
    desc.html_safe
  end

  def name_with_warning(app)
    app.testing? ? "#{app.name}<sup>*</sup>".html_safe : app.name
  end

  def image_for_app(app)
    image_tag(app.screenshot_url, :class => 'app-screenshot', :align => 'left', :title => "#{app.name} screenshot").html_safe
  end

  def display_app?
    request.xhr?
  end

  def display_style
    request.xhr? ? '' : 'display: none;'
  end

end
