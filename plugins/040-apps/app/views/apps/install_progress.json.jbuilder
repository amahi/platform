json.identifier params[:id]
json.content @message
json.progress @progress
json.type 'install'

if @progress == 100
	self.formats = [:html]
	json.app_content render(:partial => 'apps/app_installed', :object => @app)
elsif @progress > 100
	self.formats = [:html]
	json.app_content render(:partial => 'apps/app_failed', :object => @app)
end
