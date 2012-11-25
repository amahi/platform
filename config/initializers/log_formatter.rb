class Logger::SimpleFormatter
  def call(severity, time, progname, msg)
    if ['ERROR'].include?(severity)
      <<-eos
=======================================================================
======================= Amahi #{severity} BEGIN =======================
#{msg}
======================= Amahi #{severity} END =========================
=======================================================================
eos
    else
     "#{msg}\n"
    end
  end
end
