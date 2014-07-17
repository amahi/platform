class AddTvToShares < ActiveRecord::Migration
	def self.up
		if(Setting.get('initialized') && Setting.get('initialized') == '1')
			name = "TV"
			sh = Share.where(:name=>name).first
			if !sh
				sh = Share.new
				sh.path = Share.default_full_path(name)
				sh.name = name
				sh.rdonly = false
				sh.visible = true
				sh.tags = name.downcase
				sh.extras = ""
				sh.disk_pool_copies = 0
				sh.save!
			end
		end
	end

	def self.down
	end
end
