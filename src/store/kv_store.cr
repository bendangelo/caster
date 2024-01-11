module Store

  class KVStore
    property db : RocksDB::DB
    property last_used : Atomic(Int64)
    property last_flushed : Atomic(Int64)
    property lock : RWLock

    def initialize(@db : RocksDB::DB, @last_used :  Atomic(Int64), @last_flushed : Atomic(Int64))
      @lock = RWLock.new
    end

    def close
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
    end

    def flush
      # Generate flush options
      # flush_options = FlushOptions.new
      # flush_options.wait = true

      # Perform flush (in blocking mode)
      # @db.flush#(flush_options)
    end

    def write(batch : RocksDB::WriteBatch)
      # Configure this write
      write_options = RocksDB::WriteOptions.new

      # WAL disabled?
      if !Caster.settings.kv.database.write_ahead_log
        Log.debug { "ignoring wal for kv write" }
        write_options.disable_wal(true)
      else
        Log.debug { "using wal for kv write" }
        write_options.disable_wal(false)
      end

      # Commit this write
      @db.write_opt(batch, write_options)
    end
  end

end
