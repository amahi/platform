require 'spec_helper'
 
describe "Users tab" do
	it "an admin should be able to create a new user" do
		user = create(:admin)
		visit root_path
		expect(page).to have_content("Amahi Server Login")
		fill_in "username", :with => user.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		expect(page).to have_content("Setup")
		visit users_path
		expect(page).to have_content("Username")
		expect(page).to have_content("Full Name")
		click_button "New User"
		expect(page).to have_content("Create a New User")
		fill_in "user_login", :with => "newuser"
		fill_in "user_name", :with => "fullname"
		fill_in "user_password", :with => "secret"
		fill_in "user_password_confirmation", :with => "secret"
		click_button "user_create_button"
		visit users_path
		expect(page).to have_content("newuser")
		expect(page).to have_content("fullname")
	end
	it "should allow an admin user to delete a regular user", :js => true do
		admin = create(:admin)
		user = create(:user)
		visit root_path
		expect(page).to have_content("Amahi Server Login")
        fill_in "username", :with => admin.login
        fill_in "password", :with => "secret"
        click_button "Log In"
		expect(page).to have_content("Setup")
        visit users_path
		expect(page).to have_content("Username")
		expect(page).to have_content("Full Name")
		click_link user.login
		expect(page).to have_selector("span.delete", :visible => true, :text => user.login);
		click_link "Delete"
		expect(page).to have_no_content(user.login)
	end
	it "should not allow an admin user to delete its own account" do
		admin = create(:admin)
		visit root_path
		expect(page).to have_content("Amahi Server Login")
        fill_in "username", :with => admin.login
        fill_in "password", :with => "secret"
        click_button "Log In"
		expect(page).to have_content("Setup")
        visit users_path
		expect(page).to have_content("Username")
		expect(page).to have_content("Full Name")
		click_link admin.login
		expect(page).to have_no_selector("span.delete",:visible => true, :text => admin.login);
	end
	it "should not allow an admin user to revoke its own admin rights" do
		admin = create(:admin)
		visit root_path
		expect(page).to have_content("Amahi Server Login")
        fill_in "username", :with => admin.login
        fill_in "password", :with => "secret"
        click_button "Log In"
		expect(page).to have_content("Setup")
        visit users_path
		expect(page).to have_content("Username")
		expect(page).to have_content("Full Name")
		click_link admin.login
		expect(page.find_by_id("checkbox-user_admin_1")[:disabled]).to eq 'disabled'
	end
	it "should allow an admin user to revoke admin rights to another user" do
		admin = create(:admin)
		user = create(:admin)
		visit root_path
		expect(page).to have_content("Amahi Server Login")
        fill_in "username", :with => admin.login
        fill_in "password", :with => "secret"
        click_button "Log In"
		expect(page).to have_content("Setup")
        visit users_path
		expect(page).to have_content("Username")
		expect(page).to have_content("Full Name")
		click_link user.login
		expect(page).to have_checked_field("checkbox-user_admin_2")
		uncheck("checkbox-user_admin_2");
		expect(page).to have_unchecked_field("checkbox-user_admin_2")
	end
	it "should allow an admin user to promote a regular user to admin" do
		admin = create(:admin)
		user = create(:user)
		visit root_path
		expect(page).to have_content("Amahi Server Login")
        fill_in "username", :with => admin.login
        fill_in "password", :with => "secret"
        click_button "Log In"
		expect(page).to have_content("Setup")
        visit users_path
		expect(page).to have_content("Username")
		expect(page).to have_content("Full Name")
		click_link user.login
		expect(page).to have_unchecked_field("checkbox-user_admin_2")
		check("checkbox-user_admin_2");
		expect(page).to have_checked_field("checkbox-user_admin_2")
	end 
	it "should allow an admin user to change his full name" do
		pending
	end
	it "should allow an admin user to change the full name of another user" do
		pending
	end
	it "should allow an admin user to change his password" do
		pending
	end
	it "should allow an admin user to change another user's password" do
		pending
	end
end

