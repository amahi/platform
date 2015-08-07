require 'spec_helper'

feature "Admin creation" do

	before(:each) do
		# load the seed to get the minimum env going
		load "#{Rails.root}/db/seeds.rb"
	end

	scenario "first login for admin should see the setup page and setup first admin" do
		(s = Setting.where(:name=>'initialized').first) && s.destroy
		username = "newuser"
		User.stub(:system_find_name_by_username) { ["New User", 1000, username] }
		visit start_path
		expect(page).to have_content("Amahi initialization")
		fill_in "username", :with => username
		fill_in "password", :with => "secret"
		fill_in "password_confirmation", :with => "secret"
		click_button "Create"
		user = User.where(:login => username).first
		user.admin.should be_truthy
	end

end
