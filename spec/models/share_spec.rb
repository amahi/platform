require 'spec_helper'

describe Share do

	before(:each) do
		create(:admin)
		create(:setting, name: "net", value: "1")
		create(:setting, name: "self-address", value: "1")
	end

	it "should have a valid factory" do
		create(:share).should be_valid
	end

	it "should be invalid without a valid name" do
		expect { create(:share, name: nil) }.to raise_error
		expect { create(:share, name: "") }.to raise_error
		expect { create(:share, name: "this name is too long because it is over 32 chars") }.to raise_error
		expect { 2.times{ create(:share, name: "not_unique") } }.to raise_error # name must be unique
	end

	it "should be invalid without a valid path" do
		expect { create(:share, path: nil) }.to raise_error
		expect { create(:share, path: "this path is too way long because it has more than sixty four characters") }.to raise_error
	end

	describe "::create_default_shares" do

		it "should create default shares with the following attributes" do
			Share.create_default_shares

			Share::DEFAULT_SHARES.each do |share_name|
				share_id = Share::DEFAULT_SHARES.index(share_name) + 1

				share = Share.find(share_id)
				share.name.should             == share_name
				share.path.should             == "#{Share::DEFAULT_SHARES_ROOT}/#{share_name.downcase}"
				share.rdonly.should           == false
				share.visible.should          == true
				share.everyone.should         == true
				share.tags.should             == share_name.downcase
				share.disk_pool_copies.should == 0
				share.guest_access.should     == false
				share.guest_writeable.should   == false
			end
		end

		it "should have read and write access for all users" do
			new_user_1 = create(:user)
			new_user_2 = create(:user)
			Share.create_default_shares
			Share.all.each do |share|
				User.all.each do |user|
					share.users_with_share_access.should include(user)
					share.users_with_write_access.should include(user)
				end
			end
		end

	end

	describe "a user's accessibility to a share" do

		it "should give a user read and write access if the share has everyone: true" do
			user = create(:user)
			share = create(:share)
			share.users_with_share_access.should include(user)
			share.users_with_write_access.should include(user)
		end

		it "should NOT give a user readn and write access if the share has everyone: false" do
			user = create(:user)
			share = create(:share, everyone: false)
			share.users_with_share_access.should_not include(user)
			share.users_with_write_access.should_not include(user)
		end

	end

end

