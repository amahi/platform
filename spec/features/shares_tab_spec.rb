require 'spec_helper'

feature "Shares tab" do
  before do
    @admin = create(:admin)
    visit root_path
    page.should have_content("Amahi Server Login")
    fill_in "username", :with => @admin.login
    fill_in "password", :with => "secret"
    click_button "Log In"
    page.should have_content("Setup")
    visit shares_path
  end

  feature "Creating a new share" do
    before do
      click_button "New Share"
    end

    scenario "Admin should be able to create a new share" do
      fill_in "Name", :with => "testShare"
      click_button "Create"
      wait_for_ajax
      visit shares_path
      page.should have_content("Shares")
      page.should have_content("Location")
      page.should have_content "testShare"
      page.should have_content '\hda\testShare'
    end

    scenario "Cannot create a share with no name" do
      click_button "Create"
      wait_for_ajax
      page.should have_content "can't be blank"
    end

    scenario "Cannot create share with a duplicate name" do
      share = create(:share)
      visit shares_path
      click_button "New Share"
      fill_in "Name", :with => share.name
      click_button "Create"
      wait_for_ajax
      page.should have_content "has already been taken"
    end
  end

  feature "Deleting a share" do
    before { @share = create(:share) }

    scenario "Admin should be able to delete share" do
      visit shares_path
      click_link @share.name
      click_link "Delete #{@share.name}"
      wait_for_ajax
      visit shares_path
      page.should_not have_content @share.name
    end
  end

end