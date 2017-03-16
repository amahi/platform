# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'simplecov'
require 'simplecov_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'factory_girl_rails'

# turn this to true to get screenshots and html in tmp/capybara/*
SCREENSHOTS_ON_FAILURES=false

if SCREENSHOTS_ON_FAILURES
	require 'capybara-screenshot/rspec'
end

#reguired for using transactional fixtures with javascript driver
ActiveRecord::ConnectionAdapters::ConnectionPool.class_eval do
	def current_connection_id
		Thread.main.object_id
	end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
	# ## Mock Framework
	#
	# If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
	#
	# config.mock_with :mocha
	# config.mock_with :flexmock
	# config.mock_with :rr
	# config.mock_with :rspec

	# Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
	# config.fixture_path = "#{::Rails.root}/spec/fixtures"

	# If you're not using ActiveRecord, or you'd prefer not to run each of your
	# examples within a transaction, remove the following line or assign false
	# instead of true.
	config.use_transactional_fixtures = true

	# If true, the base class of anonymous controllers will be inferred
	# automatically. This will be the default behavior in future versions of
	# rspec-rails.
	config.infer_base_class_for_anonymous_controllers = false

	# Run specs in random order to surface order dependencies. If you find an
	# order dependency and want to debug it, you can fix the order by providing
	# the seed, which is printed after each run.
	#     --seed 1234
	config.order = "random"

	config.include FactoryGirl::Syntax::Methods

	#change the default javascript driver to webkit
	config.before(:suite) do
		Capybara.javascript_driver = :poltergeist
		Capybara.default_driver = :poltergeist
	end
	config.after(:each) do
		Capybara.reset_sessions!
	end

	if SCREENSHOTS_ON_FAILURES
		Capybara::Screenshot.autosave_on_failure = true
	end

end

# This is to stub with RSpec in FactoryGirl
FactoryGirl::SyntaxRunner.class_eval do
  include RSpec::Mocks::ExampleMethods
end
