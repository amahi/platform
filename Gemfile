source 'https://rubygems.org'

gem 'rake'

gem "rails", '~>5.2.0'

gem "yettings"

gem 'sass-rails'
gem 'coffee-rails'

gem 'therubyracer'

gem 'uglifier'

gem 'activeresource'
gem 'actionpack-action_caching'
gem 'actionview'
gem 'rails-observers'

gem 'jbuilder'
gem 'ya2yaml'

gem 'bootstrap', '~> 4.1.1'
gem 'popper_js', '~> 1.12.9'

gem 'bootsnap', require: false

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
	# turn this on to enable reporting on best practices with:
	#	rails_best_practices -f html .
	# gem 'rails_best_practices'

	gem 'listen'

	# FIXME: for Fedora only
	if ((open('/etc/issue').grep(/fedora/i).length > 0) rescue false)
		gem "minitest"
	end

	gem 'better_errors'
	gem 'binding_of_caller'

	gem 'puma'

	# DB performance warnings
  gem 'bullet'
end

gem "rspec-rails", :group => [:test, :development]

group :test do
  gem "factory_bot_rails"
  gem "capybara"
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

group :development, :production do
	gem 'mysql2'
end

group :development, :test do
	gem 'sqlite3'
end

# this is somehow needed for nokogiri
gem 'mini_portile2',  '~> 2.3.0'
gem "nokogiri", :require => "nokogiri"
