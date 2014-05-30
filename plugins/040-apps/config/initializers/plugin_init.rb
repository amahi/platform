# plugin initialization
t = Tab.find_or_create("apps", "apps", "/tab/apps")
# add any subtabs with what you need. params are controller and the label, for example
t.add("index", "available")
t.add("installed", "installed")
# comment out for now
# t.add("webapps", "webapps")
