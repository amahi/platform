# Amahi Home Server
# Copyright (C) 2007-2013 Amahi
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License v3
# (29 June 2007), as published in the COPYING file.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# file COPYING for more details.
# 
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Amahi
# team at http://www.amahi.org/ under "Contact Us."

require 'socket'
require 'yettings'

class Command

	CMD_FIFO = "/var/run/hda-ctl/notify"
	HDACTL_PID = "/var/run/hda-ctl.pid"

	@cmd = []

	def initialize(cmd = nil)
		@cmd = cmd ? [cmd] :  []
		@dummy_mode = Yetting.dummy_mode
	end

	def execute
		return if @dummy_mode
		puts "EXECUTING: #{@cmd.join "\n"}" if @debug
		raise "hda-ctl does not appear to be running!" unless running?
		command = @cmd.join "\n"
		f = UNIXSocket.open(CMD_FIFO)
		f.send(command, 0)
		f.close
		@cmd = []
	end

	def run_now
		raise "hda-ctl does not appear to be running!" unless running?
		confirm = "done" # Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
		@cmd.push "confirm: #{confirm}\n"
		command = @cmd.join "\n"
		f = UNIXSocket.open(CMD_FIFO)
		f.send(command, 0)
		f.flush
		begin
			r = f.read;
			r.strip!
		end until r == confirm or f.eof
		raise "error run_now - did not get confirmation of command completion." unless r == confirm
		f.close
		@cmd = []
	end

	def submit(command)
		# FIXME - check for allowed commands?
		# here and perhaps in the daemon.
		@cmd.push command
	end

private
	def running?
		begin
			f = File.open HDACTL_PID
			s = f.readline
			f.close
			s.chomp!
			File.exists?("/proc/#{s}") ? true : false
		rescue
			false
		end
	end

end
