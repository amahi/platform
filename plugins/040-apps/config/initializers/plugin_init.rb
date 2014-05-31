# plugin initialization
unless t = Tab.find("apps")
	t = Tab.new("apps", "apps", "/tab/apps")
end
# add any subtabs with what you need. params are controller and the label, for example
t.add("index", "available")
t.add("installed", "installed")
# comment out for now
# t.add("webapps", "webapps")
