require 'spec_helper'

feature "Users tab" do
  before do
    @admin = create(:admin)
    @user = create(:user)
    visit root_path
    expect(page).to have_content("Amahi Server Login")
    fill_in "username", :with => @admin.login
    fill_in "password", :with => "secretpassword"
    click_button "Log In"
    element = page.find('.nav-item', visible: :all, text: 'Setup')
    expect(element).to match_css('.nav-item', visible: :all)
    visit users_engine.users_path
    expect(page).to have_content("Username")
    expect(page).to have_content("Full Name")
  end
	scenario "an admin should be able to create a new user", :js => true do
		click_button "New User"
		fill_in "user_login", :with => "newuser"
		fill_in "user_name", :with => "fullname"
		fill_in "user_password", :with => "secretpassword"
		fill_in "user_password_confirmation", :with => "secretpassword"
		click_button "user_create_button"
		wait_for_ajax
		visit users_engine.users_path
		expect(page).to have_content("newuser")
		expect(page).to have_content("fullname")
	end
	scenario "should allow an admin user to delete a regular user", :js => true do
		find("#whole_user_#{@user.id}").find("tr").click_link @user.login
		expect(page).to have_selector("a#delete-user-#{@user.id}", :visible => true)
		click_link "delete-user-#{@user.id}"
		expect(page).to have_no_content(@user.name)
	end
	scenario "should not allow an admin user to delete its own account" do
		find("#whole_user_#{@admin.id}").find("tr").click_link @admin.login
		expect(page).to have_no_selector("a#delete-user-#{@user.id}", :visible => true)
	end
	scenario "should not allow an admin user to revoke its own admin rights", :js => true do
		find("#whole_user_#{@admin.id}").find("tr").click_link @admin.login
		expect(page.find_by_id("checkbox_user_admin_#{@admin.id}")[:disabled]).to eq true
	end
	scenario "should allow an admin user to revoke admin rights to another user", :js => true do
		user = create(:admin)
		visit users_engine.users_path
		find("#whole_user_#{user.id}").find("tr").click_link user.login
		checkbox = "checkbox_user_admin_#{user.id}"
		expect(page).to have_checked_field(checkbox)
		page.uncheck(checkbox)
		wait_for_ajax
		expect(page).to have_unchecked_field(checkbox)
		expect(user.reload.admin?).to eq false
	end
	scenario "should allow an admin user to promote a regular user to admin", :js => true do
		find("#whole_user_#{@user.id}").find("tr").click_link @user.login
		checkbox = "checkbox_user_admin_#{@user.id}"
		expect(@user.admin?).to eq false
		expect(page).to have_no_checked_field(checkbox)
		page.check(checkbox)
		wait_for_ajax
		expect(page).to have_checked_field(checkbox)
		expect(@user.reload.admin?).to eq true
	end
	scenario "should allow an admin user to change his full name", :js => true do
		user_link = find("#whole_user_#{@admin.id}")
		user_link.find("tr").click_link @admin.login
		expect(user_link).to have_selector("a.name_click_change", :visible => true)
		link = user_link.find("a.name_click_change", :visible => true)
		link.click
		expect(page).to have_button('Change')
		expect(page).to have_field("name",:with=>"#{@admin.name}")
		within("#form_user_#{@admin.id}") do
			fill_in "name" ,:with=>"changedname"
			click_button "Change"
			wait_for_ajax
		end
		expect(user_link.find("table.settings")).to have_content("changedname")
		expect(@admin.reload.name).to eq "changedname"
	end
	scenario "should allow an admin user to change the full name of another user", :js => true do
		user_link = find("#whole_user_#{@user.id}")
		user_link.find("tr").click_link @user.login
		expect(user_link).to have_selector("a.name_click_change", :visible => true)
		link = user_link.find("a.name_click_change", :visible => true)
		link.click
		expect(page).to have_button('Change')
		expect(page).to have_field("name",:with=>"#{@user.name}")
		within("#form_user_#{@user.id}") do
			fill_in "name" ,:with=>"changedname"
			click_button "Change"
			wait_for_ajax
		end
		expect(user_link.find("table.settings")).to have_content("changedname")
		expect(@user.reload.name).to eq "changedname"
	end
	scenario "should allow an admin user to change his password" do
		user_link = find("#whole_user_#{@admin.id}")
		user_link.find("tr").click_link @admin.login
		within(user_link) do
			expect(user_link).to have_selector("a#user-password-control-action-#{@admin.id}", :visible => true)
			link = user_link.find_by_id("user-password-control-action-#{@admin.id}")
			link.click
			expect(user_link).to have_field("user[password]")
			expect(user_link).to have_field("user[password_confirmation]")
			password_input = user_link.find_field("user[password]")
			password_confirm_input = user_link.find_field("user[password_confirmation]")
			password_input.set "secretpassword"
			password_confirm_input.set "secretpassword"
			submit_link = user_link.find_by_id("submit_password_#{@admin.id}")
			submit_link.click
			wait_for_ajax
		end
		expect(@admin.reload.password).to eq "secretpassword"
	end
	scenario "should allow an admin user to change another user's password" do
		user_link = find("#whole_user_#{@user.id}")
		user_link.find("tr").click_link @user.login
		within(user_link) do
			expect(user_link).to have_selector("a#user-password-control-action-#{@user.id}", :visible => true)
			link = user_link.find_by_id("user-password-control-action-#{@user.id}")
			link.click
			expect(user_link).to have_field("user[password]")
			expect(user_link).to have_field("user[password_confirmation]")
			password_input = user_link.find_field("user[password]")
			password_confirm_input = user_link.find_field("user[password_confirmation]")
			password_input.set "secretpassword"
			password_confirm_input.set "secretpassword"
			submit_link = user_link.find_by_id("submit_password_#{@user.id}")
			submit_link.click
			wait_for_ajax
		end
		expect(@user.reload.password).to eq "secretpassword"
  end

end
