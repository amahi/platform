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

class Host < ActiveRecord::Base

	after_save :restart
	after_create :restart
	after_destroy :restart

	attr_accessible :name, :mac, :address

	validates :name, presence: true, format: { with: /\A[a-z][a-z0-9-]*\z/i }, uniqueness: true
	validates :mac, presence: true, uniqueness: true, format: { with: /\A([0-9a-f]{2}:){5}([0-9a-f]{2})\z/i }
	# FIXME - this assumes we do not know about the DHCP dynamic ranges
	validates :address, presence: true, uniqueness: true, numericality: { greater_than: 0, less_than: 255, only_integer: true }

	protected

	def restart
		# FIXME - only do named
		system "hda-ctl-hup"
	end
end
