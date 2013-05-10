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

require 'leases'

class NetworkController < ApplicationController
  before_filter :admin_required
  before_filter :set_page_title

  def index
    @leases = use_sample_data? ? SampleData.load('leases') : Leases.all
  end

  def hosts
    get_hosts
  end

  def create_host
    sleep 2 if development?
    @host = Host.create params[:host]
    get_hosts
  end

  def destroy_host
    sleep 2 if development?
    @host = Host.find params[:id]
    @host.destroy
    render json: { id: @host.id }
  end

private
  def set_page_title
    @page_title = t('network')
  end

  def get_hosts
    @hosts = Host.all
    @net = Setting.get 'net'
  end
end
