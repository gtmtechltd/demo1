require './logger.rb'
require './server.rb'

Logger.setLogLevel(Logger::LOGLEVEL_TRACE)
Logger.debug("This server runs on pid #{$$}")

server = Server.new
ProcfsMapper.ignore_pid($$)

server.start!
