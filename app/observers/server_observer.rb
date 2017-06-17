require 'platform'

class ServerObserver < ActiveRecord::Observer

  def before_save(server)
    if server.monitored_changed?
      server.monitored ? monit_file_add(server) : monit_file_remove(server)
      # DEBUG RAILS_DEFAULT_LOGGER.info "* * * MONITORED CHANGED to #{monitored}"
    end
    if server.start_at_boot_changed?
      server.start_at_boot ? service_enable(server) : service_disable(server)
      # DEBUG RAILS_DEFAULT_LOGGER.info "* * * START_AT_BOOT CHANGED to #{start_at_boot}"
    end
  end

  def after_create(server)
    c = Command.new enable_cmd(server)
    c.submit start_cmd(server)
    c.execute
    monit_file_add(server)
  end

  def after_destroy(server)
    c = Command.new("rm -f #{File.join(Platform.file_name(:monit_dir), Platform.service_name(server.name))}.conf")
    c.submit Platform.watchdog_restart_command
    c.submit disable_cmd(server)
    c.submit stop_cmd(server)
    c.execute
  end

protected

  def start_cmd(server)
		Platform.service_start_command(server.name)
	end

	def stop_cmd(server)
		Platform.service_stop_command(server.name)
	end

	def enable_cmd(server)
		Platform.service_enable_command(server.name)
	end

	def disable_cmd(server)
		Platform.service_disable_command(server.name)
	end

  def service_enable(server)
		c = Command.new enable_cmd(server)
		c.execute
	end

	def service_disable(server)
		c = Command.new disable_cmd(server)
		c.execute
	end

  def cmd_file(server)
		"# WARNING - This file was automatically generated on #{Time.now}\n"	\
		"check process #{server.clean_name} with pidfile \"#{server.pid_file}\"\n"	\
        	"\tstart program = \"#{start_cmd(server)}\"\n"				\
        	"\tstop  program = \"#{stop_cmd(server)}\"\n"
	end

  def monit_file_add(server)
		fname = TempCache.unique_filename "server-#{server.name}"
		open(fname, "w") { |f| f.write cmd_file(server) }
		c = Command.new "cp -f #{fname} #{File.join(Platform.file_name(:monit_dir), Platform.service_name(server.name))}.conf"
		c.submit "rm -f #{fname}"
		c.submit Platform.watchdog_restart_command
		c.execute
	end

	def monit_file_remove(server)
		c = Command.new("rm -f #{File.join(Platform.file_name(:monit_dir), Platform.service_name(server.name))}.conf")
		# FIXME - this conrestart does not help on ubuntu, as there is no such thing
		c.submit Platform.watchdog_restart_command
		c.execute
	end

end
