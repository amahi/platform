# plugin initialization
t = Tab.new("apps", "apps", "/tab/apps")
# add any subtabs with what you need. params are controller and the label, for example
t.add("index", "details")
t.add("installed", "installed")
t.add("webapps", "webapps")
