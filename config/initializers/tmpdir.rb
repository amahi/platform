# temp dir for our own use
if Rails.env != "production"
	# used in development
	HDA_TMP_DIR = File.join(Rails.root, 'tmp/cache/tmpfiles')
else
	HDA_TMP_DIR = '/var/hda/tmp'
end

if Rails.env=="test"
  FAKE_APP =  OpenStruct.new({
      :id => 'xyz',
      :name => 'testapp',
			:screenshot_url => "app.screenshot_url",
			:identifier => "xyz",
			:description => "app.description",
			:app_url => "app.url",
			:logo_url => "app.logo_url",
			:status => "app.status"
  })
  FAKE_APP_INSTALLER = OpenStruct.new({
			"source_url"=>nil,
			"source_sha1"=>nil,
      "identifier" => 'xyz',
			"url_name"=>"php5",
			"webapp_custom_options"=>nil,
      "database"=>"php5-container",
			"initial_user"=>"php5-container",
			"initial_password"=>"php5-container",
			"special_instructions"=>nil,
			"install_script"=>"cat > html/index.php << 'EOF'\n<?php\necho \"testing\";\n?>\nEOF\n",
			"status"=>"testing", "id"=>"tqt7pwn1w1",
			"server"=>nil, "share"=>nil,
			"app_dependencies"=>nil,
			"pkg_dependencies"=>nil,
			"pkg"=>nil,
			"version"=>"0.1"
	})
end

FileUtils.mkdir_p(HDA_TMP_DIR)
