require 'spec_helper'

feature "Network tab" do
	before do
		@admin = create(:admin)
		visit root_path
		fill_in "username", :with => @admin.login
		fill_in "password", :with => "secretpassword"
		click_button "Log In"
		visit network_engine.root_path
	end

	scenario "Admin should be able to create fixed IPs" do
		visit network_engine.hosts_path
		click_button "New Fixed IP"
		fill_in "host[name]" ,:with=> "testIP"
		fill_in "host[mac]" ,:with=> "11:22:33:44:55:66"
		fill_in "host[address]" ,:with=> "10"
		click_button "host_create_button"
		wait_for_ajax
		expect(page).to have_content("testIP")
		expect(page).to have_content("192.168.1.10")
	end

	scenario "Admin should be able to create DNS aliases" do
		visit network_engine.dns_aliases_path
		click_button "New DNS Alias"
		fill_in "dns_alias[name]" ,:with=> "testdns"
		fill_in "dns_alias[address]" ,:with=> "10"
		click_button "dns_alias_create_button"
		wait_for_ajax
		expect(page).to have_content("testdns")
		expect(page).to have_content("192.168.1.10")
	end
end
