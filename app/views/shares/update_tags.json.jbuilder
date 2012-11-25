self.formats = [:html]
json.status @saved ? 200 : 500
json.content render(:partial => 'tags', :object => @share)