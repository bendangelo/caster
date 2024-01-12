module Executer
  class Count
    def self.execute(item : Store::Item)

      collection, bucket, object = item.collection, item.bucket, item.object
      if collection && bucket && object
        # general_kv_access_lock_read!

        kv_store = Store::KVPool.acquire(Store::KVAcquireMode::OpenOnly, collection)
        kv_action = Store::KVAction.new bucket: bucket, store: kv_store

        oid = object
        iid = kv_action.get_oid_to_iid(oid)

        return 0 if iid.nil?

        terms = kv_action.get_iid_to_terms(iid)

        return 0 if terms.nil?

        return terms.size
      elsif collection && bucket
        # general_fst_access_lock_read!

        # if fst_store = StoreFSTPool.acquire(collection, bucket).to_result
        #   fst_action = StoreFSTActionBuilder.access(fst_store)
        #   Ok(fst_action.count_words.to_u32)
        # else
        #   nil
        # end
      elsif collection
        # StoreFSTMisc.count_collection_buckets(collection).to_result.map(&.to_u32)
      end

      0
    end
  end
end
