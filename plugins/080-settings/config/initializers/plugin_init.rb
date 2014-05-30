# plugin initialization
unless t = Tab.find("settings")
	t = Tab.new("settings", "settings", "/tab/settings")
end
# add any subtabs with what you need. params are controller and the label
t.add("index", "details")
t.add("servers", "servers", true)
t.add("themes", "themes")
