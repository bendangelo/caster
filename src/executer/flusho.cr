module Executer
  class FlushO
    def self.execute(item : Store::Item)
      collection, bucket, object = item.collection, item.bucket, item.object

      if collection && bucket && object
        # general_kv_access_lock_read!

        kv_store = Store::KVPool.acquire(Store::KVAcquireMode::OpenOnly, collection)

        # executor_kv_lock_write!(kv_store)

        kv_action = Store::KVAction.new(bucket: bucket, store: kv_store)

        oid = object

        if iid = kv_action.get_oid_to_iid(oid)
          count_flushed = 0

          iid_terms = kv_action.get_iid_to_terms(iid)

          if iid_terms.nil?
            Log.debug { "iid term not found for #{iid}" }
            return 0
          end

          if batch_count = kv_action.batch_flush_bucket(iid, oid, iid_terms)
            count_flushed += batch_count
          else
            Log.error { "failed executing batch-flush-bucket in flusho executor" }
          end

          return count_flushed
        else
          Log.error { "failed getting flusho executor oid-to-iid" }
        end
      end

      return 0
    end
  end
end
