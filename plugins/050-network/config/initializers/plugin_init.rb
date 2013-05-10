# plugin initialization
t = Tab.new("network", "network", "/tab/network")
# add any subtabs with what you need. params are controller and the label, for example
t.add("index", "leases")
t.add("hosts", "hosts")
# advanced settings
t.add("dns_aliases", "dns_aliases", true)
t.add("settings", "settings", true)
