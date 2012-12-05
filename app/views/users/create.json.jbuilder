self.formats = [:html]

if @user.errors.any?
  json.status :not_accepted
  json.content render(:partial => 'users/form', :object => @user)
else
  json.status :ok
  json.content render(:template => 'users/index')
end
