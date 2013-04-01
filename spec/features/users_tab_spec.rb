require 'spec_helper'

feature "Users tab" do
	scenario "an admin should be able to create a new user" do
		user = create(:admin)
		visit root_path
		page.has_text?("Amahi Server Login")
		fill_in "username", :with => user.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		page.has_text?("Setup")
		visit users_engine.users_path
		page.has_text?("Username")
		page.has_text?("Full Name")
		click_button "New User"
		fill_in "user_login", :with => "newuser"
		fill_in "user_name", :with => "fullname"
		fill_in "user_password", :with => "secret"
		fill_in "user_password_confirmation", :with => "secret"
		click_button "user_create_button"
		visit users_engine.users_path
		page.has_text?("newuser")
		page.has_text?("fullname")
	end
	scenario "should allow an admin user to delete a regular user", :js => true do
		admin = create(:admin)
		user = create(:user)
		visit root_path
		page.has_text?("Amahi Server Login")
		fill_in "username", :with => admin.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		page.has_text?("Setup")
		visit users_engine.users_path
		page.has_text?("Username")
		page.has_text?("Full Name")
		find("#whole_user_#{user.id}").find("tr.alt-row").click_link user.login
		expect(page).to have_selector("a#delete-user-#{user.id}", :visible => true);
		click_link "delete-user-#{user.id}"
		page.has_no_text?(user.name)
	end
	scenario "should not allow an admin user to delete its own account" do
		admin = create(:admin)
		user = create(:user)
		visit root_path
		page.has_text?("Amahi Server Login")
		fill_in "username", :with => admin.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		page.has_text?("Setup")
		visit users_engine.users_path
		page.has_text?("Username")
		page.has_text?("Full Name")
		find("#whole_user_#{admin.id}").find("tr.alt-row").click_link admin.login
		expect(page).to have_no_selector("a#delete-user-#{user.id}", :visible => true)
	end
	scenario "should not allow an admin user to revoke its own admin rights" do
		admin = create(:admin)
		user = create(:user)
		visit root_path
		page.has_text?("Amahi Server Login")
		fill_in "username", :with => admin.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		page.has_text?("Setup")
		visit users_engine.users_path
		page.has_text?("Username")
		page.has_text?("Full Name")
		find("#whole_user_#{admin.id}").find("tr.alt-row").click_link admin.login
		expect(page.find_by_id("checkbox-user_admin_#{admin.id}")[:disabled]).to eq 'disabled'
	end
	scenario "should allow an admin user to revoke admin rights to another user" do
		admin = create(:admin)
		user = create(:admin)
		visit root_path
		page.has_text?("Amahi Server Login")
		fill_in "username", :with => admin.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		page.has_text?("Setup")
		visit users_engine.users_path
		page.has_text?("Username")
		page.has_text?("Full Name")
		find("#whole_user_#{user.id}").find("tr.alt-row").click_link user.login
		expect(page).to have_checked_field("checkbox-user_admin_#{user.id}")
		uncheck("checkbox-user_admin_#{user.id}");
		expect(page).to have_unchecked_field("checkbox-user_admin_#{user.id}")
	end
	scenario "should allow an admin user to promote a regular user to admin" do
		admin = create(:admin)
		user = create(:user)
		visit root_path
		page.has_text?("Amahi Server Login")
		fill_in "username", :with => admin.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		page.has_text?("Setup")
		visit users_engine.users_path
		page.has_text?("Username")
		page.has_text?("Full Name")
		find("#whole_user_#{user.id}").find("tr.alt-row").click_link user.login
		expect(page).to have_unchecked_field("checkbox-user_admin_#{user.id}")
		check("checkbox-user_admin_#{user.id}");
		expect(page).to have_checked_field("checkbox-user_admin_#{user.id}")
	end
	scenario "should allow an admin user to change his full name" do
		pending
	end
	scenario "should allow an admin user to change the full name of another user" do
		pending
	end
	scenario "should allow an admin user to change his password" do
		pending
	end
	scenario "should allow an admin user to change another user's password" do
		pending
	end
end

