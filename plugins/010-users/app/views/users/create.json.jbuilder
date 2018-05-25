self.formats = [:html]

if @user.errors.any?
  json.content render(:partial => 'form', :object => @user)
  json.errors true
else
  @user = nil
  json.content render(:template => 'users/index')
end

json.status :ok
