module Store

  class StoreKVBuilder
    # def self.open(collection_hash : StoreKVAtom) -> Result(DB, DBError)
    #   debug "opening key-value database for collection: <#{collection_hash.to_s(16)}>"
    #
    #   # Configure database options
    #   db_options = configure
    #
    #   # Open database at path for collection
    #   DB.open(db_options, path(collection_hash))
    # end
    #
    # def self.close(collection_hash : StoreKVAtom)
    #   debug "closing key-value database for collection: <#{collection_hash.to_s(16)}>"
    #
    #   store_pool_write = STORE_POOL.write
    #   collection_target = StoreKVKey.from_atom(collection_hash)
    #
    #   store_pool_write do |store_pool|
    #     store_pool.delete(collection_target)
    #   end
    # end
    #
    # def self.path(collection_hash : StoreKVAtom) : Path
    #   APP_CONF.store.kv.path / "#{collection_hash.to_s(16)}"
    # end
    #
    # def self.configure : DBOptions
    #   debug "configuring key-value database"
    #
    #   # Make database options
    #   db_options = DBOptions.new
    #
    #   # Set static options
    #   db_options.create_if_missing(true)
    #   db_options.use_fsync = false
    #   db_options.compaction_style = DBCompactionStyle::Level
    #   db_options.min_write_buffer_number = 1
    #   db_options.max_write_buffer_number = 2
    #
    #   # Set dynamic options
    #   db_options.compression_type = APP_CONF.store.kv.database.compress ? DBCompressionType::Zstd : DBCompressionType::None
    #
    #   db_options.max_open_files = APP_CONF.store.kv.database.max_files.to_i32.or(-1)
    #   db_options.increase_parallelism(APP_CONF.store.kv.database.parallelism.to_i32)
    #   db_options.max_subcompactions = APP_CONF.store.kv.database.max_compactions.to_u32
    #   db_options.max_background_jobs = (APP_CONF.store.kv.database.max_compactions + APP_CONF.store.kv.database.max_flushes).to_i32
    #   db_options.write_buffer_size = APP_CONF.store.kv.database.write_buffer * 1024
    #
    #   db_options
    # def self.build(pool_key : StoreKVKey) : Result(StoreKV, Nil)
    #   open(pool_key.collection_hash).and_then do |db|
    #     now = Time.utc_now
    #
    #     Result::Ok(StoreKV.new(
    #       database: db,
    #       last_used: Arc.new(RwLock.new(now)),
    #       last_flushed: Arc.new(RwLock.new(now)),
    #       lock: RwLock.new(false),
    #     ))
    #   end.tap do |result|
    #     result.err do |err|
    #       error "failed opening kv: #{err}"
    #     end
    #   end
    # end
  end
end
