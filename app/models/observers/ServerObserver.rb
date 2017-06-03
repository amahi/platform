class ServerObserver < ActiveRecord::Observer

  def before_save(server)
    if server.monitored_changed?
      server.monitored? server.monit_file_add : server.monit_file_remove
      # DEBUG RAILS_DEFAULT_LOGGER.info "* * * MONITORED CHANGED to #{monitored}"
    end
    if server.start_at_boot_changed?
      server.start_at_boot ? server.service_enable : server.service_disable
      # DEBUG RAILS_DEFAULT_LOGGER.info "* * * START_AT_BOOT CHANGED to #{start_at_boot}"
    end
  end

  def after_create(server)
    c = Command.new server.enable_cmd
    c.submit server.start_cmd
    c.execute
    server.monit_file_add
  end

  def after_destroy(server)
    c = Command.new("rm -f #{File.join(Platform.file_name(:monit_dir), Platform.service_name(server.name))}.conf")
    c.submit Platform.watchdog_restart_command
    c.submit server.disable_cmd
    c.submit server.stop_cmd
    c.execute
  end

end
