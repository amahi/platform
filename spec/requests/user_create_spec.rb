

require 'spec_helper'

describe "Users tab" do
	it "an admin should be able to create a new user" do
		user = create(:admin)
                visit root_path
                page.should have_content("Amahi Server Login")
                fill_in "username", :with => user.login
                fill_in "password", :with => "secret"
                click_button "Log In"
                page.should have_content("Setup")
		visit users_path
		page.should have_content("Username")
		page.should have_content("Full Name")
		click_button "New User"
		page.should have_content("Create a New User")
		fill_in "user_login", :with => "newuser"
		fill_in "user_name", :with => "fullname"
		fill_in "user_password", :with => "secret"
		fill_in "user_password_confirmation", :with => "secret"
		click_button "user_create_button"
		visit users_path
		page.should have_content("newuser")
		page.should have_content("fullname")
	end
end

