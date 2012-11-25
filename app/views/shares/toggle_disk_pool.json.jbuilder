self.formats = [:html]
json.status 200
json.content render(:partial => 'shares/disk_pool', :object => @share)
