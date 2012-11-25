self.formats = [:html]

if @user.errors.any?
  json.status 500
  json.content render(:partial => 'users/form', :object => @user)
else
  json.status 200
  json.content render(:template => 'users/index')
end