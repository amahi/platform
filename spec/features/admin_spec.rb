require 'spec_helper'

feature "Admin" do

	scenario "user should see the setup pages after login" do
		user = create(:admin)
		visit root_path
		expect(page).to have_content("Amahi Server Login")
		fill_in "username", :with => user.login
		fill_in "password", :with => "secretpassword"
		click_button "Log In"
		expect(page).to have_content("Dashboard")
		expect(page).to have_content("Setup")
		expect(page).to have_content("Logout")
	end

	scenario "non-admin users should not see the setup pages after login" do
		user = create(:user)
		visit root_path
		expect(page).to have_content("Amahi Server Login")
		fill_in "username", :with => user.login
		fill_in "password", :with => "secretpassword"
		click_button "Log In"
		expect(page).not_to have_content("Setup")
		visit users_engine.users_path
		expect(page).to have_content('You must have admin privileges to access this area')
	end

end
