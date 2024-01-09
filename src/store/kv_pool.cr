module Store
  class StoreKVPool
    # def self.count : Int32
    #   STORE_POOL.read!.size
    # end
    #
    # def self.acquire(mode : StoreKVAcquireMode, collection : String) : Result(StoreKVBox, Nil)
    #   collection_str = collection
    #   pool_key = StoreKVKey.from_str(collection_str)
    #
    #   # Freeze acquire lock, and reference it in context
    #   # Notice: this prevents two databases on the same collection to be opened at the same time.
    #   _acquire = STORE_ACQUIRE_LOCK.lock
    #
    #   # Acquire a thread-safe store pool reference in read mode
    #   store_pool_read = STORE_POOL.read!
    #
    #   if store_kv = store_pool_read[pool_key]
    #     proceed_acquire_cache("kv", collection_str, pool_key, store_kv).map { |result| Some(result) }
    #   else
    #     info "kv store not in pool for collection: #{collection_str} #{pool_key}"
    #
    #     # Important: we need to drop the read reference first, to avoid
    #     #   dead-locking when acquiring the RWLock in write mode in this block.
    #     store_pool_read = nil
    #
    #     # Check if can open database?
    #     can_open_db = if mode == StoreKVAcquireMode::OpenOnly
    #                     StoreKVBuilder.path(pool_key.collection_hash).exists
    #                   else
    #                     true
    #                   end
    #
    #     # Open KV database? (ie. we do not need to create a new KV database file tree if
    #     #   the database does not exist yet on disk and we are just looking to read data from
    #     #   it)
    #     if can_open_db
    #       proceed_acquire_open("kv", collection_str, pool_key, STORE_POOL).map { |result| Some(result) }
    #     else
    #       Ok(nil)
    #     end
    #   end
    # end
    #
    # def self.janitor
    #   proceed_janitor(
    #     "kv",
    #     STORE_POOL,
    #     APP_CONF.store.kv.pool.inactive_after,
    #     STORE_ACCESS_LOCK,
    #   )
    # end
    #
    # def self.backup(path : Path) : Result(Nil, IO::Error)
    #   debug "backing up all kv stores to path: #{path}"
    #
    #   # Create backup directory (full path)
    #   path.mkdir
    #
    #   # Proceed dump action (backup)
    #   dump_action("backup", APP_CONF.store.kv.path, path, &backup_item)
    # end
    #
    # def self.restore(path : Path) : Result(Nil, IO::Error)
    #   debug "restoring all kv stores from path: #{path}"
    #
    #   # Proceed dump action (restore)
    #   dump_action("restore", path, APP_CONF.store.kv.path, &restore_item)
    # end
    #
    # def self.flush(force : Bool)
    #   debug "scanning for kv store pool items to flush to disk"
    #
    #   # Acquire flush lock, and reference it in context
    #   # Notice: this prevents two flush operations to be executed at the same time.
    #   _flush = STORE_FLUSH_LOCK.lock
    #
    #   # Step 1: List keys to be flushed
    #   keys_flush = STORE_POOL.read!.select do |key, store|
    #     # Important: be lenient with the system clock going back to a past duration since
    #     #   we may be running in a virtualized environment where the clock is not guaranteed
    #     #   to be monotonic. This is done to avoid poisoning associated mutexes by
    #     #   crashing on unwrap().
    #     not_flushed_for = store.last_flushed.read.elapsed || Duration::ZERO
    #
    #     if force || not_flushed_for >= APP_CONF.store.kv.database.flush_after
    #       info "kv key: #{key} not flushed for: #{not_flushed_for.seconds}, may flush"
    #       true
    #     else
    #       debug "kv key: #{key} not flushed for: #{not_flushed_for.seconds}, no flush"
    #       false
    #     end
    #   end
    #
    #   # Exit trap: Nothing to flush yet? Abort there.
    #   if keys_flush.empty?
    #     info "no kv store pool items need to be flushed at the moment"
    #     return
    #   end
    #
    #   # Step 2: Flush KVs, one-by-one (sequential locking; this avoids global locks)
    #   count_flushed = 0
    #
    #   keys_flush.each do |key, store|
    #     debug "kv key: #{key} flush started"
    #
    #     if store.flush.error?
    #       error "kv key: #{key} flush failed: #{store.flush.error.message}"
    #     else
    #       count_flushed += 1
    #       debug "kv key: #{key} flush complete"
    #       end
    #
    #     # Bump 'last flushed' time
    #     store.last_flushed.write = SystemTime.now
    #
    #     # Give a bit of time to other threads before continuing
    #     Process.yield
    #   end
    #
    #   info "done scanning for kv store pool items to flush to disk (flushed: #{count_flushed})"
    # end
    #
    # def dump_action(
    #   action : String,
    #   read_path : Path,
    #   write_path : Path,
    #   fn_item : (Path, Path, String) -> Result(Nil, IO::Error)
    # ) : Result(Nil, IO::Error)
    # # Iterate on KV collections
    # for collection in Dir.new(read_path)
    # collection_name = collection.name
    #
    # # Actual collection found?
    # if collection.file_type.directory? && collection_name
    #   debug "kv collection ongoing #{action}: #{collection_name}"
    #
    #   fn_item.call(write_path, collection.path, collection_name)
    # end
    # end
    #
    # Ok

  # def backup_item(
  #   backup_path : Path,
  #   _origin_path : Path,
  #   collection_name : String
  # ) : Result(Nil, IO::Error)
  # # Acquire access lock (in blocking write mode), and reference it in context
  # # Notice: this prevents store to be acquired from any context
  # access = STORE_ACCESS_LOCK.write
  #
  # # Generate path to KV backup
  # kv_backup_path = backup_path / collection_name
  #
  # debug "kv collection: #{collection_name} backing up to path: #{kv_backup_path}"
  #
  # # Erase any previously-existing KV backup
  # if kv_backup_path.exists?
  #   kv_backup_path.delete(true)
  # end
  #
  # # Create backup folder for collection
  # kv_backup_path.mkdir
  #
  # # Convert names to hashes (as names are hashes encoded as base-16 strings, but we need
  # #   them as proper integers)
  # if collection_radix = RadixNum.from_str(collection_name, ATOM_HASH_RADIX)
  #   if collection_hash = collection_radix.as_decimal.to_i64
  #     origin_kv = StoreKVBuilder.open(collection_hash as StoreKVAtom)
  #       .try do |kv|
  #       kv or raise io_error("database open failure")
  #     end
  #
  #     # Initialize KV database backup engine
  #     kv_backup_options = DBBackupEngineOptions.new(kv_backup_path)
  #       .try do |options|
  #       options or raise io_error("backup engine options acquire failure")
  #     end
  #     kv_backup_environment = DBEnv.new
  #       .try do |environment|
  #       environment or raise io_error("backup engine environment acquire failure")
  #     end
  #
  #     kv_backup_engine = DBBackupEngine.open(kv_backup_options, kv_backup_environment)
  #       .try do |engine|
  #       engine or raise io_error("backup engine failure")
  #     end
  #
  #     # Proceed actual KV database backup
  #     kv_backup_engine.create_new_backup(origin_kv)
  #       .try do
  #       info "kv collection: #{collection_name} backed up to path: #{kv_backup_path}"
  #     rescue ex
  #       raise io_error("database backup failure: #{ex.message}")
  #       end
  #   end
  # end
  #
  # Ok
  # end
  #
  # def restore_item(
  #   _backup_path : Path,
  #   origin_path : Path,
  #   collection_name : String
  # ) : Result(Nil, IO::Error)
  # # Acquire access lock (in blocking write mode), and reference it in context
  # # Notice: this prevents store to be acquired from any context
  # access = STORE_ACCESS_LOCK.write
  #
  # debug "kv collection: #{collection_name} restoring from path: #{origin_path}"
  #
  # # Convert names to hashes (as names are hashes encoded as base-16 strings, but we need
  # #   them as proper integers)
  # if collection_radix = RadixNum.from_str(collection_name, ATOM_HASH_RADIX)
  #   if collection_hash = collection_radix.as_decimal.to_i64
  #     # Force a KV store close
  #     StoreKVBuilder.close(collection_hash as StoreKVAtom)
  #
  #     # Generate path to KV
  #     kv_path = StoreKVBuilder.path(collection_hash as StoreKVAtom)
  #
  #     # Remove existing KV database data?
  #     if kv_path.exists?
  #       kv_path.delete(true)
  #     end
  #
  #     # Create KV folder for collection
  #     kv_path.mkdir
  #
  #     # Initialize KV database backup engine
  #     kv_backup_options = DBBackupEngineOptions.new(origin_path)
  #       .try do |options|
  #       options or raise io_error("backup engine options acquire failure")
  #     end
  #     kv_backup_environment = DBEnv.new
  #       .try do |environment|
  #       environment or raise io_error("backup engine environment acquire failure")
  #     end
  #
  #     kv_backup_engine = DBBackupEngine.open(kv_backup_options, kv_backup_environment)
  #       .try do |engine|
  #       engine or raise io_error("backup engine failure")
  #     end
  #
  #     kv_backup_engine.restore_from_latest_backup(kv_path, kv_path, DBRestoreOptions.default)
  #       .try do
  #       info "kv collection: #{collection_name} restored to path: #{kv_path} from backup: #{origin_path}"
  #     rescue ex
  #       raise io_error("database restore failure: #{ex.message}")
  #       end
  #   end
  # end
  #
  # Ok
  end
end

