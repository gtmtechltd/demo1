require 'socket'
require './logger.rb'
require './http_stream.rb'
require './event_handler.rb'

class Server

  include EventHandler
  attr_reader :streams

  DEFAULT_HOST    = "localhost"
  DEFAULT_PORT    = "1337"
  TRAPPED_SIGNALS = ["INT", "TERM", "QUIT", "KILL", "HUP"]

  def initialize
    @streams = []
    @host    = DEFAULT_HOST
    @port    = DEFAULT_PORT
    @@accepting_new_connections = true
    @connection_id = 0

    Logger.info "PS Server v0.1\nGeoff Meakin\n\nType ==> curl http://localhost:1337/ps for ps goodness"
  end

  def to_io
    @io
  end

  def stop
    @running = false
  end

  def select
    watchables = [self] + @streams
    readables, writables = IO.select(watchables, watchables)
    readables.each { |readable| readable.selected_read }
    writables.each { |writable| writable.selected_write }
  end

  def start!
    @running = true
    @io = TCPServer.new(@host, @port)
    TRAPPED_SIGNALS.each do |signal|
      Signal.trap(signal) { interrupt }
    end
    select while @running
  end

  def interrupt
    Logger.info("Interrupt received. Gracefully shutting down")
    @streams.each do |stream|
      stream.interrupt
    end if @@accepting_new_connections == true
    @@accepting_new_connections = false
    Logger.info("Gracefully exiting")
    exit 0
  end

  def selected_read
    begin
      @connection_id += 1 
      sock = @io.accept_nonblock
      stream = HttpStream.new(sock, @connection_id)
      @streams << stream
      Logger.debug("New connection received [#{@connection_id}]")
      stream.on(:close) do
        Logger.warn("Closing connection #{stream.connection_id}")
        begin ; stream.io.close ; rescue ; end
        @streams.delete(stream)
      end
    rescue Exception => e
      Logger.trace("Socket was select(2) for read, but then not readable. Warrants investigation (#{e.message})")
    end if @@accepting_new_connections
  end

  def selected_write
    # meaningless here
  end

end
