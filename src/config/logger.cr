# Using crystal's standard environment variables:
# CRYSTAL_LOG_LEVEL=INFO
# CRYSTAL_LOG_SOURCES=*

module Caster

  class Logger

    def self.setup
      Colorize.enabled = Caster.settings.colorize

      backend = Log::IOBackend.new(STDOUT)

      backend.formatter = Log::Formatter.new do |entry, io|
        io << entry.timestamp.to_s("%I:%M:%S")
        # io << entry.timestamp.in(time_zone).to_s("%I:%M:%S")
        io << " "
        io << entry.source
        if entry.severity > Log::Severity::Debug
          case entry.severity
          when Log::Severity::Info
            io << " [#{entry.severity}]".colorize(:green)
          when Log::Severity::Warn
            io << " [#{entry.severity}]".colorize(:yellow)
            when Log::Severity::Error
              io << " [#{entry.severity}]".colorize(:red)
            else
              io << entry.message
              end
        end
        io << " "
        io << entry.message
      end

      Log.builder.clear
      Log.builder.bind "*", Log::Severity.parse(Caster.settings.log_level), backend
    end
  end

end
