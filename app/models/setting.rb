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

class Setting < ActiveRecord::Base

	attr_accessible :name, :value, :kind

	scope :by_name, lambda{|name| where(:name => name)}
	scope :by_kind, lambda{|kind| where(:kind => kind)}

	scope :general, by_kind('general')
	scope :network, by_kind('network')
	scope :shares,  by_kind('shares')


	class << self

		def value_by_name(name)
			get_by_name(name).try(:value)
		end

		def get_by_name(name)
			by_name(name).first
		end

		def get(name)
			s = by_name(name).first
			s && s.value
		end

		def set(name, value)
			general.find_or_create_by_name(:name => name).update_attribute(:value, value)
		end

		def get_kind(kind, name)
			by_kind(kind).by_name(name).first
		end

		def set_kind(kind, name, value)
			setting = get_kind(kind, name)
			if setting
				s.update_attribute!(:value, value)
			else
				setting = create(:kind => kind, :name => name, :value => value)
			end
			setting
		end
	end

	def set?
		value == '1' || value == 'true'
	end


end
