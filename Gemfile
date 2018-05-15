source 'https://rubygems.org'

gem 'rake'

gem "rails", '~>5.1.0'

gem "yettings"

gem 'sass-rails'
gem 'coffee-rails'

gem 'therubyracer'

gem 'uglifier'

gem 'activeresource'
gem 'protected_attributes_continued'
gem 'actionpack-action_caching'
gem 'actionview'
gem 'rails-observers'

gem 'jbuilder'
gem 'ya2yaml'

gem 'bootstrap', '~> 4.1.1'
gem 'popper_js', '~> 1.12.9'

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
	gem 'byebug'
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
  gem "capybara"
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'byebug'
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

# this is somehow needed for nokogiri
gem 'mini_portile2',  '~> 2.3.0'
gem "nokogiri", :require => "nokogiri"
