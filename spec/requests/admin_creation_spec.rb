require 'spec_helper'

describe "Admin creation" do

	before(:each) do
		# load the seed to get the minimum env going
		load "#{Rails.root}/db/seeds.rb"
	end

	it "first login for admin should see the setup page and setup first admin" do
		username = "newuser"
		User.stub(:system_find_name_by_username) { ["New User", 500] }
		visit root_path
		page.should have_content("Amahi Server Login")
		fill_in "username", :with => username
		fill_in "password", :with => "secret"
		click_button "Log In"
		page.should have_content("First admin setup. Please re-create your user password.")
		fill_in "password", :with => "secret"
		fill_in "password_confirmation", :with => "secret"
		click_button "Create"
		user = User.find_by_login username
		user.admin.should be_true
	end

end
