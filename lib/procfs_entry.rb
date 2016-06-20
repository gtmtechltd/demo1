require './json.rb'

class ProcfsEntry                                   # Process is a reserved word

  attr_accessor :cmdline, :ppid, :name, :environ
  attr_reader   :pid

  def initialize pid
    @pid     = pid
    @ppid    = -1
    @cmdline = false   
    @environ = []
    parse_procfs
  end

  def parse_procfs
    @cmdline = parse_cmdline
    @ppid    = parse_ppid
    @name    = parse_name
    @environ = parse_environ
  end
    
  def parse_cmdline
    cmdline = begin
      IO.read("/proc/#{@pid}/cmdline").tr("\000", ' ').strip
    rescue
      nil
    end
    if cmdline.nil? or cmdline.empty? then false else cmdline end
  end

  def parse_ppid
    begin
      stat = IO.read("/proc/#{@pid}/stat")
      stat[ /\(.*\)/ ] = '()'              # Remove the comm stat[1] as it can
                                           # contain spaces and parentheses
      stat.split(' ')[3]
    rescue
      -1
    end
  end

  def parse_name
    begin
      IO.read("/proc/#{@pid}/comm").chop  # kernel >= 2.6.33 . Would use stat[1] otherwise
    rescue
      "** unknown **"
    end
  end

  def parse_environ
    begin
      IO.read("/proc/#{@pid}/environ").split("\0")
    rescue Errno::EACCES, Errno::ESRCH, Errno::ENOENT
      []
    end
  end

  def to_hash
    {
      :cmdline     => @cmdline || false,   # nil would be better default
      :ppid        => @ppid,
      :name        => @name,
      :environment => @environ
    }
  end

  def to_json( indentation = 0 )
    to_hash.to_json( indentation )
  end

end
