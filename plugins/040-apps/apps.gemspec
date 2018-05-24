$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "apps/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "apps"
  s.version     = Apps::VERSION
  s.authors     = ["Carlos Puchol & Solomon Seal"]
  s.email       = ["slm4996+git@gmail.com"]
  s.homepage    = "http://www.amahi.org"
  s.license     = "AGPLv3"
  s.summary     = %{Amahi app management plugin.}
  s.description = %{This is an Amahi 7 platform plugin to install and manage apps.}

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 5.2"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
