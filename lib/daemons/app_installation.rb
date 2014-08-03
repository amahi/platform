#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")


$running = true
Signal.trap("TERM") do
  $running = false
  Rails.logger.info ("died")
end

Rails.logger.auto_flushing = true if Rails.logger.respond_to?(:auto_flushing)


AmahiApi::api_key = Setting.value_by_name("api-key")

while $running do
  # Replace this with your code
    identifier = Setting.value_by_name("app_api")#Right now using the db value
    #identifier = AmahiApi::AppToInstall

    #App instalaltion starts if there is some app to install
    if !identifier.nil?
      @app = App.where(:identifier=>identifier).first
    App.install identifier unless @app
    File.open('log/app_installation.rb.log','a') do |f|
      f.write('App installation of '+identifier+"started  at #{Time.now}\n")
    end
    Setting.set("app_api",nil) #if Rails.env == "development"
    sleep(180)
  else
    sleep(10)
  end
end
