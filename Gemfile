source 'https://rubygems.org'

gem 'rails', '3.2.10'

gem 'mysql2'
gem "yettings"

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  # trying libv8 to see if things work on travis ci
  gem "libv8", "~> 3.11.8.4"

  gem 'uglifier', '>= 1.0.3'
end

gem 'jbuilder'
gem 'ya2yaml'

gem 'themes_for_rails'

gem 'compass-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'slim'

gem 'authlogic'

gem 'bcrypt-ruby', '~> 3.0.0'

gem 'unicorn'

group :development do
	gem 'quiet_assets'
	gem 'thin'
end

gem 'pluginfactory'

gem "rspec-rails", :group => [:test, :development]
group :test do
  gem 'sqlite3'
  gem "factory_girl_rails"
  gem "capybara"
  # FIXME: required for Fedora 17
  gem 'minitest'
  #required for javascript test in selenium
  gem 'poltergeist'
end

