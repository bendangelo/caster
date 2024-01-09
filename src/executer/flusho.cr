module Executer
  class FlushO
    # def self.execute(store : StoreItem) : Result(Int32, Nil)
    #   if let StoreItem(collection, Some(bucket), Some(object)) = store
    #     general_kv_access_lock_read!
    #
    #     if let Ok(kv_store) = StoreKVPool.acquire(StoreKVAcquireMode::OpenOnly, collection)
    #       executor_kv_lock_write!(kv_store)
    #
    #       kv_action = StoreKVActionBuilder.access(bucket, kv_store)
    #
    #       oid = object.as_str
    #
    #       if let Ok(iid_value) = kv_action.get_oid_to_iid(oid)
    #         count_flushed = 0
    #
    #         if let Some(iid) = iid_value
    #           iid_terms = kv_action.get_iid_to_terms(iid).unwrap_or_default
    #
    #           if let Ok(batch_count) = kv_action.batch_flush_bucket(iid, oid, iid_terms)
    #             count_flushed += batch_count
    #           else
    #             error "failed executing batch-flush-bucket in flusho executor"
    #           end
    #         end
    #
    #         return Ok(count_flushed)
    #       else
    #         error "failed getting flusho executor oid-to-iid"
    #       end
    #     end
    #   end
    #
    #   Err(Nil)
    # end
  end
end
