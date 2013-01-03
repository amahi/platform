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

class ShareController < ApplicationController
	before_filter :admin_required

	VALID_NAME = Regexp.new "^\\w[\\w ]+$"
	# Disk Pool minimum free: default og 10GB, but for root,
	# 20GB. so that when all drives are full, / should still have 10GB free.
	DP_MIN_FREE_DEFAULT = 10
	DP_MIN_FREE_ROOT = 20

	def update_name
		# FIXME - lots of checks missing!
		s = Share.find(params[:id])
		s.name = params[:value]
		s.save
		s.reload
		render :text => s.name
	end

	def update_extras
		# FIXME - lots of checks missing!
		s = Share.find(params[:id])
		s.extras = params[:value]
		s.save
		s.reload
		extras = s.extras.blank? ? t('add_extra_parameters') : s.extras
		render :text => extras
	end

	def update_path
		# FIXME - lots of checks missing!
		s = Share.find(params[:id])
		s.path = params[:value]
		s.save
		s.reload
		render :text => s.path
	end

	def update_tags
		# FIXME - lots of checks missing!
		s = Share.find(params[:id])
		s.tags = params[:value].downcase
		s.save
		s.reload
		render :text => s.tags
	end

	def delete
		s = Share.find params[:id]
		s.destroy
		shares = Share.all.sort { |x,y| x.name.casecmp y.name }
		render :partial => 'share/list', :locals => { :shares => shares }
	end

	def create
		nm = params[:name]
		path = params[:path]
		if nm.nil? or nm.blank? or ((not (valid_name?(nm))) or (nm.size > 32) or (path.size > 64))
			flash.now[:error] = "Bad share name!"
			render :text => "", :status => 403
			return
		end
		if path.nil? or path.blank?
			render :text => "", :status => 401
			return
		end
		v = params[:visible] ? true : false
		r = params[:readonly] ? true : false
		s = Share.new(:name => nm, :path => path, :visible => v, :rdonly => r)
		s.save!
		shares = Share.all.sort { |x,y| x.name.casecmp y.name }
		render :partial => "share/body", :locals => { :shares => shares }
	end

	def new_share_name_check
		sn = params[:name]
		if sn.nil? or sn.blank?
			render :partial => 'share/name_cannot_be_blank'
			return false
		end
		if (not (valid_name?(sn))) or (sn.size > 32)
			render :partial => 'share/name_invalid'
			return false
		end
		share = Share.find_by_name(sn)
		if share
			render :partial => 'share/name_not_available'
			return false
		else
			@name = sn
			render :partial => 'share/name_available'
			return true
		end
	end

	def new_share_path_check
		sp = params[:path]
		if sp.nil? or sp.blank?
			render :partial => 'share/path_cannot_be_blank'
			return false
		end
		if (sp.size > 64) or (sp =~ /[\\]/)
			render :partial => 'share/path_invalid'
			return false
		end
		share = Share.find_by_path(sp)
		if share
			render :partial => 'share/path_not_available'
			return false
		else
			render :partial => 'share/path_available'
			return true
		end
	end

	def toggle_everyone
		begin
			share = Share.find params[:id]
			if share.everyone
				allu = User.all
				share.users_with_share_access = allu
				share.users_with_write_access = allu
				share.everyone = false
				share.rdonly = true
			else
				share.users_with_share_access = []
				share.users_with_write_access = []
				share.guest_access = false
				share.guest_writeable = false
				share.everyone = true
			end
			share.save
		rescue
		end
		render :partial => 'share/access', :locals => { :share => share }
	end

	def toggle_guest_access
		share = Share.find params[:id]
		if share.guest_access
			share.guest_access = false
		else
			share.guest_access = true
			# forced read-only as default
			share.guest_writeable = false
		end
		share.save
		render :partial => 'share/access', :locals => { :share => share }
	end

	def toggle_guest_writeable
		share = Share.find params[:id]
		share.guest_writeable = ! share.guest_writeable
		share.save
		render :partial => 'share/access', :locals => { :share => share }
	end

	def toggle_access
		begin
			share = Share.find params[:id]
			if share.everyone
				render :partial => 'share/access', :locals => { :share => share }
				return
			end
			user = User.find params[:user]
			if share.users_with_share_access.include? user
				share.users_with_share_access -= [user]
			else
				share.users_with_share_access += [user]
			end
			share.save
		rescue
		end
		render :partial => 'share/access', :locals => { :share => share }
	end

	def toggle_write
		begin
			share = Share.find params[:id]
			if share.everyone
				render :partial => 'share/access', :locals => { :share => share }
				return
			end
			user = User.find params[:user]
			if share.users_with_write_access.include? user
				share.users_with_write_access -= [user]
			else
				share.users_with_write_access += [user]
			end
			share.save
		rescue
		end
		render :partial => 'share/access', :locals => { :share => share }
	end

	def toggle_readonly
		begin
			share = Share.find params[:id]
			share.rdonly = ! share.rdonly
			share.save
		rescue
		end
		render :partial => 'share/access', :locals => { :share => share }
	end

	def toggle_visible
		begin
			share = Share.find params[:id]
			share.visible = ! share.visible
			share.save
		rescue
		end
		render :partial => 'share/visible', :locals => { :share => share }
	end

	def toggle_tag
		begin
			t = params[:tag]
			share = Share.find(params[:id])
			st = share.tag_list
			if st.include? t
				st -= [t]
			else
				st += [t]
			end
			share.tags = st.join ", "
			share.save
			share.reload
		rescue
		end
		render :partial => 'share/tags', :locals => { :share => share }
	end

	def toggle_setting
		id = params[:id]
		s = Setting.find id
		s.value = (1 - s.value.to_i).to_s
		s.save!
		Share.push_shares
		# artificial delay to avoid too fast restarts and double clicks
		sleep 1
		@win98 = Setting.shares.f "win98"
		@pdc = Setting.shares.f "pdc"
		@debug = Setting.shares.f "debug"
		@workgroup = Setting.shares.f "workgroup"
		render :partial => "share/settings_all"
	end

	def update_workgroup_name
		id = params[:id]
		s = Setting.find id
		v = params[:value]
		if is_valid_domain_name(v) && v != s.value
			s.value = v
			s.save
			Share.push_shares
		end
		s.reload
		render :text => s.value
	end

	def toggle_disk_pool_enabled
		share = Share.find params[:id]
		if share.disk_pool_copies > 0
			share.disk_pool_copies = 0
		else
			share.disk_pool_copies = 1
		end
		share.save
		share.reload
		render :partial => 'share/disk_pool_share', :locals => { :share => share }
	end

	def update_disk_pool_copies
		share = Share.find params[:id]
		share.disk_pool_copies = params[:value].to_i
		share.save
		share.reload
		render :partial => 'share/disk_pool_share', :locals => { :share => share }
	end

	def toggle_disk_pool_partition
		path = params[:path]
		part = DiskPoolPartition.find_by_path(path)
		if part
			# was enabled - disable it by deleting it
			# FIXME - see http://bugs.amahi.org/issues/show/510
			part.destroy
			render :partial => 'share/disk_pooling_partition_checkbox', :locals => { :checked => false, :path => path }
		else
			# if the path is not really a partition or a mountpoint - ignore it and never enable it!
			if PartitionUtils.new.info.select{|p| p[:path] == path}.empty? or not Pathname.new(path).mountpoint?
				render :partial => 'share/disk_pooling_partition_checkbox', :locals => { :checked => false, :path => path }
			else
				min_free = path == '/' ? DP_MIN_FREE_ROOT : DP_MIN_FREE_DEFAULT
				DiskPoolPartition.create(:path => path, :minimum_free => min_free)
				render :partial => 'share/disk_pooling_partition_checkbox', :locals => { :checked => true, :path => path }
			end
		end
	end

	private

	def is_valid_domain_name(domain)
		return false if domain.size > 15 || domain.size < 1
		return false unless domain =~ /^[A-z][A-z_0-9]*$/
		true
	end

	def valid_name?(nm)
		return false unless (nm =~ VALID_NAME)
		true
	end

	# translate windows location \\hda\path\to\folder to file /var/hda/files/path/to/folder
	def location2file(loc)
		rest = loc.gsub(/^\\([A-Z0-9a-z_]*)/, '')
		# FIXME - no way to replace backslashes in ruby?!?!
		rest.gsub!(/\\/, '/')
		Share.full_path(rest)
	end

end
