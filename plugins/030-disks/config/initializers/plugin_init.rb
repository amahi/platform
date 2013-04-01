# plugin initialization
t = Tab.new("disks", "disks", "/tab/disks")
# add any subtabs with what you need. params are controller and the label, for example
t.add("index", "details")
t.add("mounts", "partitions")
