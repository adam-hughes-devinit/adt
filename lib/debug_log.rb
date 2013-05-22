class DebugLog < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{msg}\n"
  end
end

logfile = File.open(Rails.root.to_s + '/log/debug.log', 'a')  #create log file
logfile.sync = true  #automatically flushes data to file
DBG = DebugLog.new(logfile)  #constant accessible anywhere
