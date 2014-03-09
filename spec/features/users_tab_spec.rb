require 'spec_helper'

feature "Users tab" do
  before(:each) do
    @admin = create(:admin)
    @user = create(:user)
    visit root_path
    page.has_text?("Amahi Server Login")
    fill_in "username", :with => @admin.login
    fill_in "password", :with => "secret"
    click_button "Log In"
    page.has_text?("Setup")
    visit users_engine.users_path
  end
	scenario "an admin should be able to create a new user", :js => true do
		page.has_text?("Username")
		page.has_text?("Full Name")
		click_button "New User"
		fill_in "user_login", :with => "newuser"
		fill_in "user_name", :with => "fullname"
		fill_in "user_password", :with => "secret"
		fill_in "user_password_confirmation", :with => "secret"
		click_button "user_create_button"
		wait_for_ajax
		visit users_engine.users_path
		page.has_text?("newuser")
		page.has_text?("fullname")
	end
	scenario "should allow an admin user to delete a regular user", :js => true do
		page.has_text?("Username")
		page.has_text?("Full Name")
		find("#whole_user_#{@user.id}").find("tr").click_link @user.login
		expect(page).to have_selector("a#delete-user-#{@user.id}", :visible => true)
		click_link "delete-user-#{@user.id}"
		page.has_no_text?(@user.name)
	end
	scenario "should not allow an admin user to delete its own account" do
		page.has_text?("Username")
		page.has_text?("Full Name")
		find("#whole_user_#{@admin.id}").find("tr").click_link @admin.login
		expect(page).to have_no_selector("a#delete-user-#{@user.id}", :visible => true)
	end
	scenario "should not allow an admin user to revoke its own admin rights", :js => true do
		page.has_text?("Username")
		page.has_text?("Full Name")
		find("#whole_user_#{@admin.id}").find("tr").click_link @admin.login
		expect(page.find_by_id("checkbox_user_admin_#{@admin.id}")[:disabled]).to eq 'disabled'
	end
	scenario "should allow an admin user to revoke admin rights to another user", :js => true do
    user = create(:admin)
    visit users_engine.users_path
    page.has_text?("Username")
    page.has_text?("Full Name")
    find("#whole_user_#{user.id}").find("tr").click_link user.login
    checkbox = "checkbox_user_admin_#{user.id}"
    page.should have_checked_field(checkbox)
    page.uncheck(checkbox)
    wait_for_ajax
    page.should have_unchecked_field(checkbox)
    expect(user.reload.admin?).to eq false
	end
	scenario "should allow an admin user to promote a regular user to admin", :js => true do
		page.has_text?("Username")
		page.has_text?("Full Name")
		find("#whole_user_#{@user.id}").find("tr").click_link @user.login
		checkbox = "checkbox_user_admin_#{@user.id}"
		expect(@user.admin?).to eq false
		page.should_not have_checked_field(checkbox)
		page.check(checkbox)
		wait_for_ajax
		page.should have_checked_field(checkbox)
		expect(@user.reload.admin?).to eq true
	end
	scenario "should allow an admin user to change his full name", :js => true do ##
		page.has_text?("Username")
		page.has_text?("Full Name")
		user_link = find("#whole_user_#{@admin.id}")
		user_link.find("tr").click_link @admin.login
		page.has_button?('edit')
		page.has_field?("name",:with=>"#{@admin.name}")
		within("#form_user_#{@admin.id}") do
			fill_in "name" ,:with=>"changedname"
			click_button "edit"
			wait_for_ajax
		end
		page.has_field?("name",:with=>"changedname")
		user_link.has_field?("tr",:with=>"changedname")
		expect(@admin.reload.name).to eq "changedname"
	end
	scenario "should allow an admin user to change the full name of another user", :js => true do
		page.has_text?("Username")
		page.has_text?("Full Name")
		user_link = find("#whole_user_#{@user.id}")
		user_link.find("tr").click_link @user.login
		page.has_button?('edit')
		page.has_field?("name",:with=>"#{@user.name}")
		within("#form_user_#{@user.id}") do
			fill_in "name" ,:with=>"changedname"
			click_button "edit"
			wait_for_ajax
		end
		page.has_field?("name",:with=>"changedname")
		user_link.has_field?("tr",:with=>"changedname")
		expect(@user.reload.name).to eq "changedname"
	end
	scenario "should allow an admin user to change his password" do
		page.has_text?("Username")
		page.has_text?("Full Name")
		user_link = find("#whole_user_#{@admin.id}")
		user_link.find("tr").click_link @admin.login
		within(user_link) do
			expect(user_link).to have_selector("a#user-password-control-action-#{@admin.id}", :visible => true)
			user_link.has_link?("a#user-password-control-action-#{@admin.id}")
			link = user_link.find_by_id("user-password-control-action-#{@admin.id}")
			link.click
			user_link.has_field?("user[password]")
			user_link.has_field?("user[password_confirmation]")
			password_input = user_link.find_field("user[password]")
			password_confirm_input = user_link.find_field("user[password_confirmation]")
			password_input.set "secret"
			password_confirm_input.set "secret"
			submit_link = user_link.find_by_id("submit_password_#{@admin.id}")
			submit_link.click
			wait_for_ajax
		end
		expect(@admin.reload.password).to eq "secret"
	end
	scenario "should allow an admin user to change another user's password" do
		page.has_text?("Username")
		page.has_text?("Full Name")
		user_link = find("#whole_user_#{@user.id}")
		user_link.find("tr").click_link @user.login
		within(user_link) do
			expect(user_link).to have_selector("a#user-password-control-action-#{@user.id}", :visible => true)
			user_link.has_link?("a#user-password-control-action-#{@user.id}")
			link = user_link.find_by_id("user-password-control-action-#{@user.id}")
			link.click
			user_link.has_field?("user[password]")
			user_link.has_field?("user[password_confirmation]")
			password_input = user_link.find_field("user[password]")
			password_confirm_input = user_link.find_field("user[password_confirmation]")
			password_input.set "secret"
			password_confirm_input.set "secret"
			submit_link = user_link.find_by_id("submit_password_#{@user.id}")
			submit_link.click
			wait_for_ajax
		end
		expect(@user.reload.password).to eq "secret"
	end
end

