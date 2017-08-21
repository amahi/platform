require File.dirname(__FILE__) + '/../config/environment'

App.all.each do |app|
  app.uninstall_bg
end
