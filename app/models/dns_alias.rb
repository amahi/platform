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

class DnsAlias < ActiveRecord::Base

	after_create :restart
	after_destroy :restart
	after_save :restart

	scope :user_visible, where(["address != ?", ''])

	attr_accessible :name, :address

	validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z][a-z0-9-]*\z/i }
	# FIXME: validate this OR simply empty to point to our own address
	#validates :address, presence: true, uniqueness: true, numericality: { greater_than: 0, less_than: 255 }

	protected

	def restart
		# FIXME - only do named
		system "hda-ctl-hup"
	end

end
