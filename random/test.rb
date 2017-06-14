require File.dirname(__FILE__) + '/../config/environment'


app = App.new('ldwbkzuq8c')
begin
  app.install_bg
rescue => e
  puts "File permission error occured or installation failed"
end

App.all.each do |app|
  app.uninstall_bg
end