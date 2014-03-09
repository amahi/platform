require 'spec_helper'

feature "Admin" do

  scenario 'user should not be able to access pages without login' do
    visit users_engine_path
    page.should have_content("Amahi Server Login")
    page.should have_content("You must be logged in to access this area")
    visit shares_engine_path
    page.should have_content("Amahi Server Login")
    page.should have_content("You must be logged in to access this area")
    visit disks_engine_path
    page.should have_content("Amahi Server Login")
    page.should have_content("You must be logged in to access this area")
  end

  scenario "user should be redirected to login page with unsuccessful login" do
    visit root_path
    click_button "Log In"
    page.should have_content("Amahi Server Login")
    page.should_not have_content("Logout")
  end

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
		visit users_engine.users_path
		page.should have_content('You must have admin privileges to access this area')
	end

end
