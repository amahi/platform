json.identifier  params[:id]
json.content  @app ? "<span class='uninstall_progress'>#{t('preparing_to_uninstall')}</span>".html_safe : t('this_application_is_not_installed_please_refresh')

