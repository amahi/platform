json.status  @saved ? :ok : :not_acceptable

self.formats = [:html]
json.content render(:partial => 'shares/access', :object => @share)
