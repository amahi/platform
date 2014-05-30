# plugin initialization
t = Tab.find_or_create("settings", "settings", "/tab/settings")
# add any subtabs with what you need. params are controller and the label
t.add("index", "details")
t.add("servers", "servers", true)
t.add("themes", "themes")
