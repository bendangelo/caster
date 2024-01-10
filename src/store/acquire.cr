module Store

  module GenericPool

      # def proceed_acquire_cache(
      #   kind : String,
      #   collection_str : String,
      #   pool_key : K,
      #   store : Ref(S)
      # )
      # puts "#{kind} store acquired from pool for collection: #{collection_str} (pool key: #{pool_key})"
      #
      # # Bump store last used date (avoids early janitor eviction)
      # store.ref_last_used.write do |last_used_value|
      #   last_used_value.value = Time.utc
      # end
      #
      # # Perform an early drop of the lock (frees up write lock early)
      # nil
      #
      # Ok(store)
      # end
      #
      # def proceed_acquire_open(
      #   kind : String,
      #   collection_str : String,
      #   pool_key : K,
      #   pool : Ref(RWLock(Hash(K, Ref(S))))
      # )
      # store = B.build(pool_key)
      #
      # if store.is_ok?
      #   # Acquire a thread-safe store pool reference in write mode
      #   pool.write do |store_pool_write|
      #     store_box = Ref.new(store.value)
      #     store_pool_write[pool_key] = store_box.clone
      #
      #     puts "opened and cached #{kind} store in pool for collection: #{collection_str} (pool key: #{pool_key})"
      #     Ok(store_box)
      #   end
      # else
      #   puts "failed opening #{kind} store for collection: #{collection_str} (pool key: #{pool_key})"
      #   Err(nil)
      # end
      # end

      # def proceed_janitor(
      #   kind : String,
      #   pool : Ref(RWLock(Hash(K, Ref(S)))),
      #   inactive_after : UInt64,
      #   access_lock : Ref(RWLock(Bool))
      # )
      # puts "scanning for #{kind} store pool items to janitor"
      #
      # # Acquire access lock (in blocking write mode), and reference it in context
      # # Notice: this prevents store to be acquired from any context
      # access = access_lock.write do |access|
      #   access.value = true
      # end
      #
      # removal_register = Array(K).new
      #
      # pool.read do |store_pool_read|
      #   store_pool_read.each do |collection_bucket, store|
      #     # Important: be lenient with system clock going back to a past duration, since \
      #     #   we may be running in a virtualized environment where clock is not guaranteed \
      #     #   to be monotonic. This is done to avoid poisoning associated mutexes by \
      #     #   crashing on unwrap().
      #     last_used_elapsed = store.ref_last_used.read do |last_used_value|
      #       last_used_value.elapsed
      #     end || Duration.new(0)
      #
      #     last_used_elapsed_secs = last_used_elapsed.to_i
      #
      #     if last_used_elapsed_secs >= inactive_after
      #       puts "found expired #{kind} store pool item: #{collection_bucket}; elapsed time: #{last_used_elapsed_secs}s"
      #       removal_register.push(collection_bucket)
      #     else
      #       puts "found non-expired #{kind} store pool item: #{collection_bucket}; elapsed time: #{last_used_elapsed_secs}s"
      #     end
      #   end
      # end
      #
      # unless removal_register.empty?
      #   pool.write do |store_pool_write|
      #     removal_register.each do |collection_bucket|
      #       store_pool_write.delete(collection_bucket)
      #     end
      #   end
      # end
      #
      # puts "done scanning for #{kind} store pool items to janitor, expired #{removal_register.size} items, now has #{pool.read { |sp| sp.size }} items"
      # end
    end
  end
