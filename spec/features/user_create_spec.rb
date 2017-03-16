require 'spec_helper'

feature "Users tab" do
  before(:each) do
    user = create(:admin)
    visit root_path
    expect(page).to have_content("Amahi Server Login")
    fill_in "username", :with => user.login
    fill_in "password", :with => "secret"
    click_button "Log In"
  end
  scenario "an admin should be able to create a new user", :js => true do
    expect(page).to have_content("Setup")
    visit users_engine.users_path
    expect(page).to have_content("Username")
    expect(page).to have_content("Full Name")
    click_button "New User"
    fill_in "user_login", :with => "newuser"
    fill_in "user_name", :with => "fullname"
    fill_in "user_password", :with => "secret"
    fill_in "user_password_confirmation", :with => "secret"
    click_button "user_create_button"
    wait_for_ajax
    visit users_engine.users_path
    expect(page).to have_content("newuser")
    expect(page).to have_content("fullname")
  end

  feature 'user information must be valid to be created' do
    scenario 'with no username' do
      visit users_engine.users_path
      click_button "New User"
      fill_in "user_name", :with => "fullname"
      fill_in "user_password", :with => "secret"
      fill_in "user_password_confirmation", :with => "secret"
      click_button "user_create_button"
      wait_for_ajax
      expect(page).to have_content "is too short (minimum is 3 characters)"
    end
    scenario 'with no full name' do
      visit users_engine.users_path
      click_button "New User"
      fill_in "user_login", :with => "newuser"
      fill_in "user_password", :with => "secret"
      fill_in "user_password_confirmation", :with => "secret"
      click_button "user_create_button"
      wait_for_ajax
      expect(page).to have_content "can't be blank"
    end
    scenario 'with no password' do
      visit users_engine.users_path
      click_button "New User"
      fill_in "user_login", :with => "newuser"
      fill_in "user_name", :with => "fullname"
      fill_in "user_password_confirmation", :with => "secret"
      click_button "user_create_button"
      wait_for_ajax
      expect(page).to have_content 'is too short (minimum is 4 characters)'
    end
    scenario 'with no password confirmation' do
      visit users_engine.users_path
      click_button "New User"
      fill_in "user_login", :with => "newuser"
      fill_in "user_name", :with => "fullname"
      fill_in "user_password", :with => "secret"
      click_button "user_create_button"
      wait_for_ajax
      expect(page).to have_content "doesn't match Password"
    end
    scenario 'when password doesnt match' do
      visit users_engine.users_path
      click_button "New User"
      fill_in "user_login", :with => "newuser"
      fill_in "user_name", :with => "fullname"
      fill_in "user_password", :with => "secret"
      fill_in "user_password_confirmation", :with => "notsecret"
      click_button "user_create_button"
      wait_for_ajax
      page.save_screenshot('image1.jpg')
      expect(page).to have_content "doesn't match Password"
    end
  end
end

