# plugin initialization
t = Tab.new("apps", "Apps", "/tab/apps")
# add any subtabs with what you need. params are controller and the label, for example
t.add("index", "All")
t.add("installed", "Installed")
t.add("webapps", "Webapps")
