self.formats = [:html]

if @user.errors.any?
  json.status :not_accepted
  json.content render(:partial => 'form', :object => @user)
else
  @user = nil
  json.status :ok
  json.content render(:template => 'users/index')
end
