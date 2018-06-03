require File.dirname(__FILE__) + '/../config/environment'

# Run 100 times

# Reset everything before starting tests
def reset(identifier)
  puts "Reseting everything. Uninstalling all the apps"
  App.all.each do |app|
    begin
      app.uninstall_bg
    rescue
      app.destroy
    end
  end

  puts "Remove containers if they are still running"
  system("docker kill #{identifier}")
  system("docker rm #{identifier}")
end


# TODO: Error logging in a separate file so that reports can be seen later on.
# TODO: Check vhost config
identifier='ldwbkzuq8c'
reset(identifier)
(1..10).each do |t|
  puts "Starting iteration #{t}"
  begin
    app = App.new({identifier: identifier})
    app.install_bg
  rescue => e
    puts "Installation failed."
    puts "This was not expected"
    raise e
  end

  puts "Sleeping before uninstallation"
  sleep(5)

  puts "Uninstallation Started"
  begin
    app = App.find_by_identifier(identifier)
    app.uninstall_bg
  rescue => e
    puts "Uninstallation failure was not expected"
    raise e
  end
end

puts "All iterations sucessful."