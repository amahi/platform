require 'spec_helper'

feature "Admin creation" do

	scenario "first login for admin should see the setup page and setup first admin" do
		(s = Setting.where(:name=>'initialized').first) && s.destroy
		username = "newuser"
		allow(User).to receive(:system_find_name_by_username) { ["New User", 1000, username] }
		visit start_path
		expect(page).to have_content("Amahi initialization")
		fill_in "username", :with => username
		fill_in "password", :with => "secretpassword"
		fill_in "password_confirmation", :with => "secretpassword"
		click_button "Create"
		user = User.where(:login => username).first
		expect(user.admin).to be_truthy
	end

end
