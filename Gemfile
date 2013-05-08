source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'mysql2'
gem "yettings"

# Commenting this out because we're not going to pre-compile assets for now
#group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  gem 'therubyracer'

  gem 'uglifier'
#end

gem 'jbuilder'
gem 'ya2yaml'

gem 'themes_for_rails'

gem 'jquery-rails'
gem 'jquery-ui-rails'
# FIXME-cpg: this requirement of 1.3.8 is because bundle update forced slim to 1.0.1! (!?)
gem 'slim', '~> 1.3.8'

gem 'authlogic'

gem 'bcrypt-ruby', '~> 3.0.0'

gem 'unicorn'

group :development do
	gem 'quiet_assets'
	gem 'thin'
	gem 'thor'
	# turn this on to enable reporting on best practices with:
	#	rails_best_practices -f html .
	# gem 'rails_best_practices'
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
end

