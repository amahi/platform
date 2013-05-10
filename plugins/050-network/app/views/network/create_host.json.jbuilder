self.formats = [:html]

if @host.errors.any?
  json.status :not_accepted
  json.content render(:partial => 'network/host_form', :object => @host)
else
  @host = nil
  json.status :ok
  json.content render(:template => 'network/hosts')
end
