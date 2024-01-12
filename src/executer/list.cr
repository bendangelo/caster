module Executer
  class List
    def self.execute(store : Store::Item, event_id : String, limit : Int32, offset : Int32)
      # if let Store::Item(collection, Some(bucket), Nil) = store
      #   general_fst_access_lock_read!
      #
      #   if let Ok(fst_store) = StoreFSTPool.acquire(collection, bucket)
      #     fst_action = StoreFSTActionBuilder.access(fst_store)
      #
      #     debug "running list"
      #
      #     return fst_action.list_words(limit.to_i32, offset.to_i32)
      #   end
      # end

      Array(String).new
    end
  end
end
