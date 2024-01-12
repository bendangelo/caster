module Store

  alias KVAtom = UInt32

  class KVBuilder
    def self.open(path)
      Log.debug { "opening key-value database for collection: <#{path}>" }

      # Configure database options
      db_options = configure

      # Open database at path for collection
      RocksDB::DB.new(path, db_options)
    end

    def self.path(collection_hash : UInt32)
      "#{Caster.settings.kv.path}/#{collection_hash}"
    end

    def self.path(collection : String)
      "#{Caster.settings.kv.path}/#{Hasher.to_compact(collection)}"
    end

    def self.configure
      Log.debug { "configuring key-value database" }

      # Make database options
      db_options = RocksDB::Options.new

      # Set static options
      db_options.set_create_if_missing(1)
      db_options.set_use_fsync(0)
      db_options.optimize_level_style_compaction(1)
      # db_options.set_min_write_buffer_number(1) # not in library
      db_options.set_max_write_buffer_number(2)

      # Set dynamic options
      # db_options.compression_type = Caster::Settings.kv.database.compress ? DBCompressionType::Zstd : DBCompressionType::None

      db_options.set_max_open_files Caster.settings.kv.database.max_files
      db_options.increase_parallelism(Caster.settings.kv.database.parallelism)
      db_options.set_max_background_compactions Caster.settings.kv.database.max_compactions
      db_options.set_max_background_flushes Caster.settings.kv.database.max_flushes
      db_options.set_write_buffer_size Caster.settings.kv.database.write_buffer * 1024

      db_options
    end

    def self.build(pool_key : UInt32)
      path = path(pool_key)
      db = open(path)

      now = Time.utc.to_unix

      KVStore.new(
        db: db,
        path: path,
        last_used: Atomic.new(now),
        last_flushed: Atomic.new(now)
      )
    end
  end
end
