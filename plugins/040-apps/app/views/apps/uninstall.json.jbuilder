json.status @status
json.identifier  params[:id]
if @status
	json.content  @app ? "<span class='uninstall_progress'>#{t('preparing_to_uninstall')}</span>".html_safe : t('this_application_is_not_installed_please_refresh')
else
	json.content "<span class='install_progress'>#{t('already_uninstallation_going_on')}</span>".html_safe
end

