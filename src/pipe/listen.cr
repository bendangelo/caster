module Pipe
  class Listen
    # CHANNEL_AVAILABLE : RWLock(Bool) = RWLock.new(true)

    def self.run
      Log.info { "listening on tcp://#{Caster.settings.inet}:#{Caster.settings.port}" }

      server = TCPServer.new(Caster.settings.inet, Caster.settings.port)
      while client = server.accept?
        spawn handle_client client
      end
    end

    def self.handle_client(stream)
      Log.debug { "channel client connecting: #{stream.remote_address}" }

      Handle.client(stream)
    end

    def self.teardown
      # Channel cannot be used anymore
      # CHANNEL_AVAILABLE.write { |lock| lock[] = false }
    end
  end
end
