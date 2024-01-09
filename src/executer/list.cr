module Executer
  class List
    # def self.execute(store : StoreItem, _event_id : QuerySearchID, limit : QuerySearchLimit, offset : QuerySearchOffset) : Result(Array(String), Nil)
    #   if let StoreItem(collection, Some(bucket), Nil) = store
    #     general_fst_access_lock_read!
    #
    #     if let Ok(fst_store) = StoreFSTPool.acquire(collection, bucket)
    #       fst_action = StoreFSTActionBuilder.access(fst_store)
    #
    #       debug "running list"
    #
    #       return fst_action.list_words(limit.to_i32, offset.to_i32)
    #     end
    #   end
    #
    #   Err(Nil)
    # Ond
  end
end
