class Logger

  LOGLEVEL_ERROR = 1
  LOGLEVEL_WARN  = 2
  LOGLEVEL_INFO  = 3
  LOGLEVEL_DEBUG = 4
  LOGLEVEL_TRACE = 5

  @@loglevel = 3

  def self.error message
    STDERR.puts self.color(message, :red) if @@loglevel >= LOGLEVEL_ERROR
  end

  def self.warn message
    STDERR.puts self.color(message, :purple) if @@loglevel >= LOGLEVEL_WARN
  end

  def self.info message
    STDOUT.puts self.color(message, :white) if @@loglevel >= LOGLEVEL_INFO
  end

  def self.debug message
    STDOUT.puts self.color(message, :blue) if @@loglevel >= LOGLEVEL_DEBUG
  end

  def self.trace message
    STDOUT.puts self.color(message, :green) if @@loglevel >= LOGLEVEL_TRACE
  end

  # helpers

  def self.setLogLevel level
    @@loglevel = level
  end

  def self.color message, color
    color_code = case color
      when :red
        "31"
      when :purple
        "35"
      when :white
        "37"
      when :blue
        "34"
      when :green
        "32"
    end
    "\e[#{color_code}m#{message}\e[0m"
  end

end
