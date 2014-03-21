require 'spec_helper'



describe User do
	before(:each) do
		create :user
	end
	
	it "should have a name" do
		expect { create(:user, name: nil) }.to raise_error
	end

	it "should be invalid without a valid login" do
		expect { create(:user, login: nil) }.to raise_error
		expect { create(:user, login: "") }.to raise_error
		expect { create(:user, login: "this login is too long because it is over 32 chars") }.to raise_error
		expect { 2.times{ create(:user, login: "not_unique") } }.to raise_error # login must be unique
	end
	
	it "should find name by username" do
		username = `echo $USER`.strip
		User.system_find_name_by_username(username).should include(`cat /etc/passwd | grep `+username+` | cut -d: -f5`.gsub(/\,/,"").strip
)
	end

	it "should find all new users" do
		v =`cat /etc/passwd | grep "/home" | grep "/bin/bash" | cut -d: -f1 | wc -l`.strip.to_i
		User.system_all_new_users.count.should == v
	end
end