module Executer
  class FlushB
    # def self.execute(store : StoreItem) : Result(UInt32, Nil)
    #   if let StoreItem(collection, Some(bucket), nil) = store
    #     general_kv_access_lock_read!
    #     general_fst_access_lock_write!
    #
    #     if kv_store = StoreKVPool.acquire(StoreKVAcquireMode::OpenOnly, collection).to_result
    #       executor_kv_lock_write!(kv_store)
    #
    #       if kv_store
    #         debug "collection store exists, erasing: #{bucket.as_str} from #{collection.as_str}"
    #
    #         kv_action = StoreKVActionBuilder.access(bucket, kv_store)
    #
    #         erase_count =
    #           begin
    #             kv_action.batch_erase_bucket.to_result
    #           rescue
    #             0
    #           end
    #
    #         if StoreFSTActionBuilder.erase(collection, Some(bucket)).is_ok?
    #           debug "done with bucket erasure"
    #           return Ok(erase_count)
    #         end
    #       else
    #         debug "collection store does not exist, consider #{bucket.as_str} from #{collection.as_str} already erased"
    #         return Ok(0)
    #       end
    #     end
    #   end
    #
    #   Err(Nil)
    # end
  end
end
