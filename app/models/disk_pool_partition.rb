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

class DiskPoolPartition < ActiveRecord::Base
	include Greyhole

  DP_MIN_FREE_DEFAULT = 10
  DP_MIN_FREE_ROOT = 20

  attr_accessible :path, :minimum_free

	after_save	:regenerate_confguration
	after_create	:regenerate_confguration
	after_destroy	:regenerate_confguration

	def self.enabled?(path)
		p = self.find_by_path(path)
		! p.nil?
	end

  class << self
    def toggle_disk_pool_partition!(path)
      part = self.find_by_path(path)
      if part
        # was enabled - disable it by deleting it
        # FIXME - see http://bugs.amahi.org/issues/show/510
        part.destroy
        return false
      else
        # if the path is not really a partition or a mountpoint - ignore it and never enable it!
        if PartitionUtils.new.info.select{|p| p[:path] == path}.empty? or not Pathname.new(path).mountpoint?
          return false
        else
          min_free = path == '/' ? DP_MIN_FREE_ROOT : DP_MIN_FREE_DEFAULT
          self.create(:path => path, :minimum_free => min_free)
          return true
        end
      end
    end
  end


protected

	def regenerate_confguration
		Greyhole.save_conf_file(DiskPoolPartition.all, Share.in_disk_pool)
	end
end
