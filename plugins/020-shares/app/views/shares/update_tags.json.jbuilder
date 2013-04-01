self.formats = [:html]
json.status @saved ? :ok : :not_accepted
json.content render(:partial => 'tags', :object => @share)
