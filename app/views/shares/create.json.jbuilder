self.formats = [:html]

if @share.errors.any?
  json.status 500
  json.content render(:partial => 'shares/form', :object => @share)
else
  json.status 200
  json.content render(:template => 'shares/index')
end