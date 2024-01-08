
# require "time"
# require "./store/fst/store_fst_pool"
# require "./store/kv/store_kv_pool"
#
# class ChannelStatistics
#   property uptime : UInt64
#   property clients_connected : UInt32
#   property commands_total : UInt64
#   property command_latency_best : UInt32
#   property command_latency_worst : UInt32
#   property kv_open_count : Int32
#   property fst_open_count : Int32
#   property fst_consolidate_count : Int32
#
#   def initialize(@uptime : UInt64, @clients_connected : UInt32, @commands_total : UInt64,
#                 @command_latency_best : UInt32, @command_latency_worst : UInt32,
#                 @kv_open_count : Int32, @fst_open_count : Int32, @fst_consolidate_count : Int32)
#   end
# end
#
# START_TIME = Time.now
# CHANNEL_AVAILABLE = Concurrent::RWLock.new(true)
# CLIENTS_CONNECTED = Concurrent::RWLock.new(0)
# COMMANDS_TOTAL = Concurrent::RWLock.new(0)
# COMMAND_LATENCY_BEST = Concurrent::RWLock.new(0)
# COMMAND_LATENCY_WORST = Concurrent::RWLock.new(0)
#
# def ensure_states
#   # Ensure all statics are initialized (a `deref` is enough to lazily initialize them)
#   [START_TIME, CLIENTS_CONNECTED, COMMANDS_TOTAL, COMMAND_LATENCY_BEST, COMMAND_LATENCY_WORST]
# end
#
# class ChannelStatistics
#   def self.gather : ChannelStatistics
#     kv_count, fst_count = [StoreKVPool.count, StoreFSTPool.count]
#
#     ChannelStatistics.new(
#       uptime: Time.now - START_TIME,
#       clients_connected: CLIENTS_CONNECTED.read,
#       commands_total: COMMANDS_TOTAL.read,
#       command_latency_best: COMMAND_LATENCY_BEST.read,
#       command_latency_worst: COMMAND_LATENCY_WORST.read,
#       kv_open_count: kv_count,
#       fst_open_count: fst_count[0],
#       fst_consolidate_count: fst_count[1]
#     )
#   end
# end
