$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "users/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "users"
  s.version     = Users::VERSION
  s.authors     = ["Carlos Puchol"]
  s.email       = ["cpg+git@amahi.org"]
  s.homepage    = "http://www.amahi.org/"
  s.license     = "AGPLv3"
  s.summary     = %{User management for the Amahi platform.}
  s.description = %{This is an Amahi 7 platform plugin that allows the management of system users.}

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 5.2"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
