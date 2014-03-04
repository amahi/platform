require 'simplecov'

SimpleCov.start('rails') do
	#Add files/directory patterns below to restrict them in test-coverage
	%w(plugins/ webapp.rb theme.rb system_utils.rb
		 sample_data.rb).each do |file|
		add_filter file
	end
end
