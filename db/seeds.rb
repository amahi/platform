# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# reset the whole app and initialize basic settings

[AppDependency,
App,
CapAccess,
CapWriter,
Db,
DnsAlias,
Host,
Server,
Share,
Theme,
User,
Setting,
WebappAlias,
Webapp].map {|c| c.destroy_all}

Setting.set('net', '192.168.1')
Setting.set('self-address', '10')
Setting.set('domain', 'amahi.net')
Setting.set('api-key', '1b6727c9170b11d6f80437eac13d7a2e143fd895')
User.create!(:login => 'admin', :name => 'Admin User', :password => 'secretpassword', :password_confirmation => 'secretpassword', :admin => true)
Setting.set('advanced', '1')
Setting.set('theme', 'default')
Setting.set('guest-dashboard', '0')
Setting.set('dns', 'opennic')
Setting.set('dns_ip_1', '173.230.156.28')
Setting.set('dns_ip_2', '23.90.4.6')
Setting.set('dnsmasq_dns', '1')
Setting.set('dnsmasq_dhcp', '1')
Setting.set('initialized', '1')
Setting.set('workgroup', 'WORKGROUP')

if Rails.env=="test"
  app =  {
      :id => 'xyz',
      :name => 'testapp',
      :screenshot_url => "app.screenshot_url",
      :identifier => "xyz",
      :description => "app.description",
      :app_url => "app.url",
      :logo_url => "app.logo_url",
      :status => "app.status"
  }

  installer = {
      "source_url"=>nil,
      "source_sha1"=>nil,
      "identifier" => 'ldwbkzuq8c',
      "url_name"=>"php5",
      "webapp_custom_options"=>nil,
      "database"=>"php5-container",
      "initial_user"=>"php5-container",
      "initial_password"=>"php5-container",
      "special_instructions"=>nil,
      "kind" => "PHP5",
      "install_script"=>"cat > html/index.php << 'EOF'\n<?php\necho \"testing\";\n?>\nEOF\n",
      "status"=>"testing", "id"=>"tqt7pwn1w1",
      "server"=>nil, "share"=>nil,
      "app_dependencies"=>nil,
      "pkg_dependencies"=>nil,
      "pkg"=>nil,
      "version"=>"0.1"
  }

  uninstaller = {
      "uninstall_script" => nil,
      "pkg" => nil
  }

  # Create a normal app
  app['identifier'] = 'normal'
  app['id'] = 'normal'
  installer['identifier'] = 'normal'
  installer['kind'] = ''
  Testapp.create(:identifier=>'normal', :installer=> installer, :info => app, :uninstaller => uninstaller)

  # Create a php5 app
  app['identifier'] = 'php5'
  app['id'] = 'php5'
  installer['identifier'] = 'php5'
  installer['kind'] = 'container-php5'
  Testapp.create(:identifier=>'php5', :installer=> installer, :info => app, :uninstaller => uninstaller)

  # create a node app
  app['identifier'] = 'node'
  app['id'] = 'node'
  installer['identifier'] = 'node'
  installer['kind'] = 'container-node'
  Testapp.create(:identifier=>'node', :installer=> installer, :info => app, :uninstaller => uninstaller)
end