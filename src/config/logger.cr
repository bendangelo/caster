# Using crystal's standard environment variables:
# CRYSTAL_LOG_LEVEL=INFO
# CRYSTAL_LOG_SOURCES=*

module Caster

  class Logger

    def self.setup
      Colorize.enabled = Caster.settings.colorize

      Log.setup_from_env

      # Log.formatter = Log::Formatter.new do |entry, io|
      #   io << entry.timestamp.to_s("%I:%M:%S")
      #   # io << entry.timestamp.in(time_zone).to_s("%I:%M:%S")
      #   io << " "
      #   io << entry.source
      #   io << " |"
      #   io << " (#{entry.severity})" if entry.severity > Log::Severity::Debug
      #   io << " "
      #   io << entry.message
      # end
    end
  end

end
