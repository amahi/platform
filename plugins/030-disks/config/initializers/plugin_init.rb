# plugin initialization
t = Tab.find_or_create("disks", "disks", "/tab/disks")
# add any subtabs with what you need. params are controller and the label, for example
t.add("index", "devices")
t.add("mounts", "partitions")
