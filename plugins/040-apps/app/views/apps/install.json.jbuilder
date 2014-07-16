json.status @status
json.identifier  params[:id]
if @status
	self.formats = [:html]
	json.content  @app ? t('this_application_is_installed_already_please_refresh') : "<span class='install_progress'>#{t('preparing_to_install')}</span>".html_safe
else
	json.content "<span class='install_progress'>#{t('already_installation_going_on')}</span>".html_safe
end