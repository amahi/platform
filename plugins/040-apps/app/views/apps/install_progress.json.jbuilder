json.identifier params[:id]
json.content @message

if @progress == 100
	self.formats = [:html]
	json.app_content render(:partial => 'apps/app_installed', :object => @app)
elsif @progress > 100
	self.formats = [:html]
	json.app_content render(:partial => 'apps/app_failed', :object => @app)
end
