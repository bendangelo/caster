module Pipe
  class Listen
    PIPE_AVAILABLE = Atomic.new(1)

    def self.run
      Log.info { "listening on tcp://#{Caster.settings.inet}:#{Caster.settings.port}" }

      PIPE_AVAILABLE.set(1)

      @@server = server = TCPServer.new(Caster.settings.inet, Caster.settings.port)

      while client = server.accept?
        spawn handle_client client
      end
    end

    def self.handle_client(stream)
      Log.info { "channel client connecting: #{stream.remote_address}" }

      Handle.client(stream)
    rescue IO::Error # tried to puts to a broken connection
      Log.info { "channel client closed by peer: #{stream.remote_address}" }
    end

    def self.available?
      PIPE_AVAILABLE.get == 1
    end

    def self.shutdown?
      !available?
    end

    def self.teardown
      # Channel cannot be used anymore
      PIPE_AVAILABLE.set(0)

      server = @@server

      if !server.nil?
        server.close

        Log.info { "TCP server closed" }
      end

    end
  end
end
