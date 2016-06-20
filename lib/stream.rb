require './event_handler.rb'

class Stream

  include EventHandler

  attr_reader :io, :connection_id

  CHUNKSIZE = 4096
  BUFFERSIZE = 1048576

  def initialize(io, connection_id)
    @io = io
    @connection_id = connection_id
    @buffer_out = ""
  end

  def to_io
    @io
  end

  def write(chunk)
    raise "Buffer full" if @buffer_out.length >= BUFFERSIZE - chunk.length
    @buffer_out.append chunk
  end

  def selected_read
    begin
      chunk = @io.read_nonblock( CHUNKSIZE )
      Logger.trace("Received: #{chunk}")
    rescue EOFError
      # There might be more to come
    rescue Exception => e
      Logger.warn("Something went wrong reading the request [#{@connection_id}] - warrants investigation (#{e.message})")
      new_event(:close)
    end
  end

  def selected_write
    return if @buffer_out.empty?                   # Nothing to do
    length = @io.write_nonblock(@buffer_out)
    @buffer_out.slice!(0, length)                  # Remove the data that was successfully written.
    new_event(:close) if @buffer_out.empty?
  rescue Exception => e
    Logger.warn("Something went wrong writing the request [#{@connection_id}] - warrants investigation (#{e.message})")
    new_event(:close) # close the stream
  end

  def interrupt
    Logger.warn("Interrupting stream #{@connection_id}")
    new_event(:close)
  end

end

