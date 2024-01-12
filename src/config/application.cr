require "socket"
require "log"
require "rocksdb"
require "yaml"
require "colorize"
require "dispatch"
require "rwlock"
require "xxhash"
require "file_utils"

require "./settings"
require "./logger"
require "./store"

require "../pipe/*"
require "../pipe/commands/*"
require "../executer/*"
require "../lexer/*"
require "../store/*"
require "../tasker/*"
require "../query/*"

module Caster

  def self.settings
    @@settings ||= Settings.from_yaml File.read Caster::Settings.settings_path
  end

  def self.boot
    Caster::Logger.setup
    Caster::Settings.load_from_env!
  end

  def self.shutdown
    Log.info {"stopping gracefully"}

    # Teardown Pipe
    Pipe::Listen.teardown

    # Perform a KV flush (ensures all in-memory changes are synced on-disk before shutdown)
    # Store::KVPool.flush(true)

    # Perform a FST consolidation (ensures all in-memory items are synced on-disk before
    #   shutdown; otherwise we would lose all non-consolidated FST changes)
    # StoreFSTPool.consolidate(true)

    sleep 1
    Log.info { "stopped" }
    exit
  end

  def self.start
    boot

    Log.info { "=== Welcome to CASTER ===" }
    Log.info { "Starting up!" }

    # Spawn tasker (background thread)
    # spawn_tasker

    Log.info { "started" }

    Signal::TERM.trap { shutdown }
    Signal::INT.trap { shutdown }
    Signal::HUP.trap { shutdown }

    # Spawn pipe (foreground thread)
    Pipe::Listen.run

  end
end

# macro gen_spawn_managed(name, method, thread_name, managed_fn)
#   def {{method.id}} : Nil
#     Log.debug("spawn managed thread: {{name}}")
#
#     worker = spawn do
#       Thread.name = {{thread_name.to_s.inspect}}
#       {{managed_fn}}.build.run
#     end
#
#     # Block on worker thread (join it)
#     has_error = if worker.value.is_a?(Exception)
#       true
#     else
#       false
#     end
#
#     # Worker thread crashed?
#     if has_error
#       Log.error("managed thread crashed ({{name}}), setting it up again")
#
#       # Prevents thread start loop floods
#       sleep 1.seconds
#
#       {{method.id}}
#     end
#   end
# end
#
# gen_spawn_managed("channel", spawn_channel, THREAD_NAME_CHANNEL_MASTER, ChannelListenBuilder)
# gen_spawn_managed("tasker", spawn_tasker, THREAD_NAME_TASKER, TaskerBuilder)
