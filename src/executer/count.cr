module Executer
  class Count
    # def self.execute(store : StoreItem) : Result(UInt32, Nil)
    #   case store
    #   when StoreItem(collection, Some(bucket), Some(object))
    #     general_kv_access_lock_read!
    #
    #     if kv_store = StoreKVPool.acquire(StoreKVAcquireMode::OpenOnly, collection).to_result
    #       executor_kv_lock_read!(kv_store)
    #       kv_action = StoreKVActionBuilder.access(bucket, kv_store)
    #
    #       oid = object.to_s
    #       result = kv_action.get_oid_to_iid(oid).to_result.on_nil { 0 }
    #                 .map do |iid|
    #                   terms = kv_action.get_iid_to_terms(iid).to_result.on_nil { [] }
    #                   terms.size.to_u32
    #                 end
    #
    #       result.or { Ok(0) }
    #     else
    #       Err(Nil)
    #     end
    #   when StoreItem(collection, Some(bucket), nil)
    #     general_fst_access_lock_read!
    #
    #     if fst_store = StoreFSTPool.acquire(collection, bucket).to_result
    #       fst_action = StoreFSTActionBuilder.access(fst_store)
    #       Ok(fst_action.count_words.to_u32)
    #     else
    #       Err(Nil)
    #     end
    #   when StoreItem(collection, nil, nil)
    #     StoreFSTMisc.count_collection_buckets(collection).to_result.map(&.to_u32)
    #   else
    #     Err(Nil)
    #   end
    # end
  end
end
