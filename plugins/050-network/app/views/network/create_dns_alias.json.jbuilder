self.formats = [:html]

if @dns_alias.errors.any?
  json.status :not_accepted
  json.content render(:partial => 'network/dns_alias_form', :object => @dns_alias)
else
  @dns_alias = nil
  json.status :ok
  json.content render(:template => 'network/dns_aliases')
end
