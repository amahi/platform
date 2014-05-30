unless t = Tab.find('users')
	t = Tab.new("users", "users", "/tab/users")
end
t.add('index', "details")
# disable settings for now
# t.add('settings', "settings")
