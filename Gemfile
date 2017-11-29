source 'https://rubygems.org'

gem 'rake'

gem "rails", '~>5.0.0'

gem 'mysql2'
gem "yettings"

gem 'sass-rails'
gem 'coffee-rails'

gem 'therubyracer'

gem 'uglifier'

gem 'activeresource', :git => "https://github.com/rails/activeresource.git", require: "active_resource"
gem 'protected_attributes_continued'
gem 'actionpack-action_caching'
gem 'rails-observers', :git => "https://github.com/rails/rails-observers.git"

gem 'jbuilder'
gem 'ya2yaml'

gem 'themes_for_rails', :git => "https://github.com/amahi/themes_for_rails.git"

gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'slim'

gem 'scrypt' # required for authlogic even though it's not used
gem 'authlogic'

gem 'bcrypt'

gem 'unicorn'

gem 'rb-readline', require: false

gem 'docker-api' # required to create and manage docker containers

group :development do
	gem 'thin'
	gem 'thor'
	# turn this on to enable reporting on best practices with:
	#	rails_best_practices -f html .
	# gem 'rails_best_practices'

	# FIXME: for Fedora only
	if ((open('/etc/issue').grep(/fedora/i).length > 0) rescue false)
		gem "minitest"
	end
end

gem "rspec-rails", :group => [:test, :development]

group :test do
  gem "sqlite3"
  gem "factory_girl_rails"
  gem "capybara", :git => "https://github.com/teamcapybara/capybara.git"
  gem 'capybara-screenshot'
	gem 'database_cleaner'
  # FIXME: required in Fedora 18 for some (packaging?) reason
  # gem 'minitest'
  # required for javascript test in selenium
  gem 'poltergeist'
  gem 'simplecov', :require => false
end

# FIXME - temporary work-around for Fedora 19
# see https://bugzilla.redhat.com/show_bug.cgi?id=979133
gem 'psych'

gem 'mini_portile2'
