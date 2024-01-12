module Tasker
  # class TaskerBuilder
  # end
  #
  # class Tasker
  #   TASKER_TICK_INTERVAL = 10.seconds
  #
  #   def self.build : Tasker
  #     Tasker.new
  #   end
  #
  #   def run
  #     puts "tasker is now active"
  #
  #     loop do
  #       # Hold for next aggregate run
  #       sleep TASKER_TICK_INTERVAL
  #
  #       puts "running a tasker tick..."
  #
  #       tick_start = Time::now
  #
  #       tick
  #
  #       tick_took = Time::now - tick_start
  #
  #       puts "ran tasker tick (took #{tick_took.to_i}s + #{(tick_took.to_f % 1 * 1000).to_i}ms)"
  #     end
  #   end
  #
  #   private def tick
  #     # Proceed all tick actions
  #
  #     # #1: Janitors
  #     Store::KVPool.janitor
  #     StoreFSTPool.janitor
  #
  #     # #2: Others
  #     Store::KVPool.flush(false)
  #     StoreFSTPool.consolidate(false)
  #   end
  # end
end
