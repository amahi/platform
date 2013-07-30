json.identifier params[:id]
json.content @message

self.formats = [:html]
json.app_content render(:partial => 'apps/app_installed', :object => @app) if @progress == 100
