require "socket"
require "log"
require "rocksdb"
require "yaml"
require "./version"

module Caster
  Log = ::Log.for("socket")

  def self.handle_client(client)
    Log.info { "Sending welcome message" }

    client.puts "CONNECTED <caster-server v#{Caster::VERSION}>"

    message = client.gets

    Log.info { "Message: (#{message})" }

    client.puts message
  end

  def self.start
    yaml = File.open("./config/settings.yml") do |file|
      YAML.parse(file)
    end

    db = RocksDB::DB.new(yaml["store"]["kv"]["path"].to_s)

    # db.put("foo", "1")
    puts db.get("foo")      # => "1"

    db.close
    puts "done"

    # puts "Running server"
    #
    # server = TCPServer.new("localhost", 1491)
    # while client = server.accept?
    #   spawn handle_client(client)
    # end

  end
end
