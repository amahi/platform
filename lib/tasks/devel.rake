desc 'various taks to manage amahi devel stuff'
namespace :devel do
	desc 'setup initial fake admin user'
	task :fake_admin => :environment do
		include AmahiLogger
		u = User.new(:login => 'admin', :password => 'admin', :admin => true)
		u.save(false)
	end
end
