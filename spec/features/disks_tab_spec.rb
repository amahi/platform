require 'spec_helper'

feature "Disks tab" do
	before do
		@admin = create(:admin)
		visit root_path
		fill_in "username", :with => @admin.login
		fill_in "password", :with => "secret"
		click_button "Log In"
		visit disks_engine_path
	end

	scenario "It should list the created disk" do
		page.should have_content I18n.translate('model')
		page.should have_content "Hitachi HDS723020BLA642"
		page.should have_content I18n.translate('device')
		page.should have_content '/dev/sda'
		page.should have_content I18n.translate('temperature')+" (C)"
		page.should have_content "25"
	end

	scenario "Switching to Fahrenheit then back to Celsius" do
		click_link "C"
		page.should have_content I18n.translate('temperature')+" (F)"
		page.should have_content "77"
		click_link "F"
		page.should have_content I18n.translate('temperature')+" (C)"
		page.should have_content "25"
	end
end
