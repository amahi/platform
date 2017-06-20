require File.dirname(__FILE__) + '/../config/environment'

identifier='ldwbkzuq8c'
app = App.new('ldwbkzuq8c')
begin
  s = Setting.find_by_kind('identifier')
  if not s.nil?
    s.destroy
  end
  app.install_bg
rescue => e
  puts e
  puts "File permission error occured or installation failed"
end

App.all.each do |app|
  #app.uninstall_bg
end
