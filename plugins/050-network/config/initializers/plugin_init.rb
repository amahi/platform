# plugin initialization
t = Tab.find_or_create("network", "network", "/tab/network")
# add any subtabs with what you need. params are controller and the label, for example
t.add("index", "leases")
t.add("hosts", "hosts")
# advanced settings
t.add("dns_aliases", "dns_aliases", true)
t.add("settings", "settings", true)
