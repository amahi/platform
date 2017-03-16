require 'spec_helper'

feature "Front page" do
	scenario "should be the login page by default" do
		visit root_path
		expect(page).to have_content("Amahi Server Login")
	end

	scenario "should be the dashboard if \"guest dashboard\" is enabled" do
		setting = Setting.where(:name=>"guest-dashboard").first
		setting.value = "1"
		setting.save
		visit root_path
		expect(page).to have_content("Dashboard")
	end

	scenario "should be the login page if \"guest dashboard\" is disabled" do
		setting = create(:setting, name: "guest-dashboard", value: "0")
		visit root_path
		expect(page).to have_content("Amahi Server Login")
	end

	scenario "should allow a user with proper username/password to login" do
		user = create(:user)
		visit root_path
		expect(page).to have_content("Amahi Server Login")
		fill_in "username", :with => user.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		expect(page).to have_content("Dashboard")
		expect(page).to have_content("Logout")
	end

	scenario "should not allow a user with bad username to login" do
		user = create(:user)
		visit root_path
		expect(page).to have_content("Amahi Server Login")
		fill_in "username", :with => "bogus"
		fill_in "password", :with => "secret"
		click_button "Log In"
		expect(page).to have_content("Error: Incorrect username or password")
		expect(page).to have_content("Amahi Server Login")
	end

	scenario "should not allow a user with bad password to login" do
		user = create(:user)
		visit root_path
		expect(page).to have_content("Amahi Server Login")
		fill_in "username", :with => user.login
		fill_in "password", :with => "bogus"
		click_button "Log In"
		expect(page).to have_content("Error: Incorrect username or password")
		expect(page).to have_content("Amahi Server Login")
	end

	scenario "should allow a user with proper username/password to login and also logout" do
		user = create(:user)
		visit root_path
		expect(page).to have_content("Amahi Server Login")
		fill_in "username", :with => user.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		expect(page).to have_content("Dashboard")
		expect(page).to have_content("Logout")
		click_link "Logout"
		expect(page).to have_content("Amahi Server Login")
	end
end
