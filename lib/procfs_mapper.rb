require './json.rb'
require './procfs_entry.rb'

class ProcfsMapper

  @@ignore_pids = []

  def self.ignore_pid pid
    Logger.warn("Ignoring pid #{pid}")
    @@ignore_pids << pid.to_s
  end

  def self.read_processes
   
    processes = {}
    Dir.foreach("/proc") do |pid|
      next unless pid =~ /^\d+$/
      next if @@ignore_pids.include? pid
      processes[ pid ] = ProcfsEntry.new( pid )
    end
    processes

  end

end

