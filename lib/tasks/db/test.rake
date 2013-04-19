namespace :db do
	namespace :test do
		task :prepare do |t|
			# seed the db with basic settings in test mode
			Rails.env = 'test'
			Rake::Task["db:seed"].invoke
		end
	end
end
