require './stream.rb'
require './procfs_mapper.rb'

class HttpStream < Stream

  attr_reader :http_in

  def initialize(io, connection_id)
    super(io, connection_id)
    @http_in = ""
  end

  def selected_read     # override
    begin
      chunk = @io.read_nonblock( CHUNKSIZE )
      @http_in += chunk
      process_http_request if http_request_complete?
    rescue EOFError
      # Waiting on more information, perhaps - keep waiting
    rescue Exception => e
      Logger.warn("Something went wrong reading the request [#{@connection_id}] (#{e.class} #{e.message})")
      new_event(:close) # close the stream
    end
  end

  def http_request_complete?
    lines        = @http_in.split("\n", -1).collect{|line| line.tr("\r", "") } # remove windows/mac line endings
    last_2_terms = lines.reverse.take(2)
    if last_2_terms == [ "", "" ] then
      Logger.trace("New HTTP request [#{@connection_id}] ==>\n#{@http_in.chop}")
      true
    else
      false
    end
  end

  def process_http_request
    lines = @http_in.split("\n")
    headers = lines[0].split(" ")
    if headers[0] == "GET" and headers[1].downcase == "/ps" then
      Logger.info("Received [#{@connection_id}] <== #{headers[0]} #{headers[1]} 200")
      # Normally you'd do more than this, but I'm not going to implement a whole webserver
      # obviously
      payload = ProcfsMapper.read_processes.to_json
      Logger.trace("Sending [#{@connection_id}] ==>\n#{payload}")
      @buffer_out = generate_http_response(200, "OK", payload)
    else
      Logger.info("Received [#{@connection_id}] <== #{headers[0]} #{headers[1]} 404")
      @buffer_out = generate_http_response(404, "Not Found", "{ \"error\": \"not found\" }")
    end
  end

  def generate_http_response(code, status, payload)
   "HTTP/1.1 #{code} #{status}\nContent-Type: text/json; charset=UTF-8\nContent-Length: #{payload.length}\n\n#{payload}"
  end
end

