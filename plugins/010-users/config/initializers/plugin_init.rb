# plugin initialization
unless t = Tab.find("users")
	t = Tab.new("users", "users", "/tab/users")
end
# add any subtabs with what you need. params are controller and the label
t.add('index', "details")
# disable settings for now
# t.add('settings', "settings")
