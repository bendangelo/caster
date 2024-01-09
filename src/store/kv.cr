# require "store_kv_key"
# require "store_kv"
# require "db_error"
# require "db/options"
# require "db/write_batch"
# require "db/write_options"
# require "time"
module Store
  class StoreKV
  #   def initialize(@database : DB, @last_used : RWLock(Time), @last_flushed : RWLock(Time), @lock : RWLock(Bool))
  #   end
  #
  #   def get(key : Slice(UInt8)) : Result(Option(Slice(UInt8)), DBError)
  #     @database.get(key)
  #   end
  #
  #   def put(key : Slice(UInt8), data : Slice(UInt8)) : Result(Nil, DBError)
  #     batch = WriteBatch.new
  #     batch.put(key, data)
  #     do_write(batch)
  #   end
  #
  #   def delete(key : Slice(UInt8)) : Result(Nil, DBError)
  #     batch = WriteBatch.new
  #     batch.delete(key)
  #     do_write(batch)
  #   end
  #
  #   private def flush : Result(Nil, DBError)
  #     flush_options = FlushOptions.new
  #     flush_options.set_wait(true)
  #     @database.flush_opt(flush_options)
  #   end
  #
  #   private def do_write(batch : WriteBatch) : Result(Nil, DBError)
  #     write_options = WriteOptions.new
  #
  #     unless APP_CONF.store.kv.database.write_ahead_log
  #       debug "ignoring wal for kv write"
  #       write_options.disable_wal(true)
  #     else
  #       debug "using wal for kv write"
  #       write_options.disable_wal(false)
  #     end
  #
  #     @database.write_opt(batch, write_options)
  #   end
  #
  #   def ref_last_used : RWLock(Time)
  #     @last_used
  #   end
  # end
  #
  # module StoreGeneric
  #   abstract def ref_last_used : RWLock(Time)
  # end
  #
  # class StoreKVActionBuilder
  #   include StoreGeneric
  #
  #   def self.access(bucket : StoreItemPart, store : StoreKVBox?) : StoreKVAction
  #     build(bucket, store)
  #   end
  #
  #   def self.erase(collection : String | Symbol, bucket : String?) : Result(UInt32, Nil)
  #     dispatch_erase("kv", collection, bucket)
  #   end
  #
  #   private def self.build(bucket : StoreItemPart, store : StoreKVBox?) : StoreKVAction
  #     StoreKVAction.new(store, bucket)
  #   end
  end
end
