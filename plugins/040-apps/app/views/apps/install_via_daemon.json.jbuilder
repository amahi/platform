json.identifier  params[:id]
json.content  @app ? t('this_application_is_installed_already_please_refresh') : "<span class='install_progress'>#{t('preparing_to_install')}</span>".html_safe