module Executer
  class FlushB
    def self.execute(item : Store::Item)
      collection, bucket = item.collection, item.bucket

      if collection && bucket
        # general_kv_access_lock_read!
        # general_fst_access_lock_write!

        kv_store = Store::KVPool.acquire(Store::KVAcquireMode::OpenOnly, collection)
        # executor_kv_lock_write!(kv_store)

        Log.debug { "collection store exists, erasing: #{bucket} from #{collection}" }

        kv_action = Store::KVAction.new(bucket: bucket, store: kv_store)

        # TODO: implement rocks write batching
        # erase_count =
        #   begin
        #     kv_action.batch_erase_bucket
        # rescue
        #   0
        # end

        # if StoreFSTActionBuilder.erase(collection, Some(bucket)).is_ok?
        #   Log.debug { "done with bucket erasure" }
        #   return Ok(erase_count)
        # end
      end

      0
    end
  end
end
