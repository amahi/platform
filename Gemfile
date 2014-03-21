source 'https://rubygems.org'

gem 'rails', '3.2.17'

gem 'mysql2'
gem "yettings"

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  gem 'therubyracer'

  gem 'uglifier'
end

gem 'jbuilder'
gem 'ya2yaml'

gem 'themes_for_rails'

gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'slim'

gem 'authlogic'

gem 'bcrypt'

gem 'unicorn'

gem 'rb-readline', require: false

group :development do
	gem 'quiet_assets'
	gem 'thin'
	gem 'thor'
	# turn this on to enable reporting on best practices with:
	#	rails_best_practices -f html .
	# gem 'rails_best_practices'

	# FIXME: for Fedora only
	if ((open('/etc/issue').grep(/fedora/i).length > 0) rescue false)
		gem 'minitest'
	end
end

gem "rspec-rails", :group => [:test, :development]
group :test do
  gem "sqlite3"
  gem "factory_girl_rails"
  gem "capybara"
  gem 'capybara-screenshot'
  # FIXME: required in Fedora 18 for some (packaging?) reason
  gem 'minitest'
  # required for javascript test in selenium
  gem 'poltergeist'
  gem 'simplecov', :require => false
end

# FIXME - temporary work-around for Fedora 19
# see https://bugzilla.redhat.com/show_bug.cgi?id=979133
gem 'psych'
