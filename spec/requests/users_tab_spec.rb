require 'spec_helper'

describe "Users tab" do

	it "should allow a user with proper username/password to login" do
		user = create(:admin)
		visit root_path
		page.should have_content("Amahi Server Login")
		fill_in "username", :with => user.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		page.should have_content("Dashboard")
		visit users_path
		page.should have_content("Users")
		page.should have_content(user.login)
		page.should have_content(user.name)
	end

end
