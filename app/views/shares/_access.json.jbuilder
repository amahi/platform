json.status  @saved ? 200 : 500

self.formats = [:html]
json.content render(:partial => 'shares/access', :object => @share)