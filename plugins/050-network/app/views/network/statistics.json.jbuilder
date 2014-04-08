self.formats = [:html]

if @status == 404
  json.status :not_accepted
  json.content render(:partial => 'network/statistics_auth_form')
else
  
  json.status :ok
  json.content render(:partial => 'network/stats_graph')
end
