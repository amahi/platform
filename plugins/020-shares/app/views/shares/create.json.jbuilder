self.formats = [:html]

if @share.errors.any?
  json.status :not_accepted
  json.content render(:partial => 'shares/form', :object => @share)
else
  @share = nil
  json.status :ok
  json.content render(:template => 'shares/index', :locals => {:include_javascript => false} )
end
