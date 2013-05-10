module NetworkHelper
  def confirm_host_destroy_message(host)
    t('are_you_sure_host', :fixed_ip => host)
  end
end
