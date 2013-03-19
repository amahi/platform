require 'spec_helper'

feature "Admin" do

	scenario "user should see the setup pages after login" do
		user = create(:admin)
		visit root_path
		page.should have_content("Amahi Server Login")
		fill_in "username", :with => user.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		page.should have_content("Dashboard")
		page.should have_content("Setup")
		page.should have_content("Logout")
	end

	scenario "non-admin users should not see the setup pages after login" do
		user = create(:user)
		visit root_path
		page.should have_content("Amahi Server Login")
		fill_in "username", :with => user.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		page.should_not have_content("Setup")
		visit users_path
		page.should have_content('You must have admin privileges to access this area')
	end

end
