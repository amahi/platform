desc 'various taks to package Amahi for release'
namespace :package do
	desc 'setup development tree for packaging'
	task :setup do
		system("rm -rf tmp/assets/*")
		system("rake --trace RAILS_ENV=production RAILS_GROUPS=assets assets:precompile")
		system("bundle install --without test --path vendor/bundle --binstubs bin/ --deployment")
	end
end
