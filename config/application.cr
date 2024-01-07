require "socket"

module Caster

  def self.handle_client(client)
    message = client.gets
    client.puts message
  end

  def self.start

    server = TCPServer.new("0.0.0.0", 8123)
    while client = server.accept?
      spawn handle_client(client)
    end
  end
end
