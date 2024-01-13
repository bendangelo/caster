module Store

  class KVStore
    property db : RocksDB::DB
    property last_used : Atomic(Int64)
    property last_flushed : Atomic(Int64)
    property lock : RWLock
    property path : String
    property opened : Bool = true

    def initialize(@db : RocksDB::DB, @last_used :  Atomic(Int64), @last_flushed : Atomic(Int64), @path : String)
      @lock = RWLock.new
    end

    def close
      Log.debug { "closing key-value database for collection: <#{path}>" }

      @opened = false
      @db.close
    end

    def get?(key : Bytes)
      @db.get?(key)
    end

    def put(key : Bytes, data : Bytes)
      @db.put(key, data)
    end

    def delete(key : Bytes)
      @db.delete key

      true
    end

    def flush
      # TODO: add flush
      Log.error { "flush not added" }
      # Generate flush options
      flush_options = RocksDB::FlushOptions.new
      flush_options.set_wait(1)

      @db.flush(flush_options)
    end

    def write(batch : RocksDB::WriteBatch)
      # Configure this write
      write_options = RocksDB::WriteOptions.new

      # WAL disabled?
      if !Caster.settings.kv.database.write_ahead_log
        Log.debug { "ignoring wal for kv write" }
        write_options.disable_wal(1)
      else
        Log.debug { "using wal for kv write" }
        write_options.disable_wal(0)
      end

      # Commit this write
      @db.write(batch, write_options)
    end
  end

end
