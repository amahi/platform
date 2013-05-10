module NetworkHelper
  def confirm_host_destroy_message(host)
    t('are_you_sure_host', :fixed_ip => host)
  end

  def confirm_dns_alias_destroy_message(dns_alias)
    t('are_you_sure_dns_alias', :dns_alias => dns_alias)
  end
end
