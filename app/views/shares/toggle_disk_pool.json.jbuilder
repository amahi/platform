self.formats = [:html]
json.status :ok
json.content render(:partial => 'shares/disk_pool', :object => @share)
