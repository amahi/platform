# plugin initialization
t = Tab.find_or_create("shares", "shares", "/tab/shares")
# add any subtabs with what you need. params are controller and the label, for example
t.add("index", "details")
#Advanced Tab, workgroup settings
t.add("settings", "settings",true)
