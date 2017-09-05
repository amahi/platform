require File.dirname(__FILE__) + '/../config/environment'

identifier='ldwbkzuq8c'
puts "Reseting everything. Uninstalling all the apps"
App.all.each do |app|
  begin
    app.uninstall_bg
  rescue
    app.destroy
  end
end

puts "Remove containers if they are still running"
begin
  system("docker kill #{identifier}")
  system("docker rm #{identifier}")
rescue
  puts "Whatever docker"
end


puts "Starting fresh installation"
begin
  app = App.new('ldwbkzuq8c')
  app.install_bg
  puts "Container started successfully"
rescue => e
  puts e
  puts "File permission error occured or installation failed"
end

