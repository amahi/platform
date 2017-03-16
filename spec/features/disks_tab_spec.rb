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
		expect(page).to have_content I18n.translate('model')
		expect(page).to have_content "Hitachi HDS723020BLA642"
		expect(page).to have_content I18n.translate('device')
		expect(page).to have_content '/dev/sda'
		expect(page).to have_content I18n.translate('temperature')+" (C)"
		expect(page).to have_content "25"
	end

	scenario "Switching to Fahrenheit then back to Celsius" do
		click_link "C"
		expect(page).to have_content I18n.translate('temperature')+" (F)"
		expect(page).to have_content "77"
		click_link "F"
		expect(page).to have_content I18n.translate('temperature')+" (C)"
		expect(page).to have_content "25"
	end
end
