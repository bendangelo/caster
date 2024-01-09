module Executer
  class FlushC
    # def self.execute(store : StoreItem) : Result(Int32, Nil)
    #   if let StoreItem(collection, Nil, Nil) = store
    #     general_kv_access_lock_write!
    #     general_fst_access_lock_write!
    #
    #     erase_count_kv = StoreKVActionBuilder.erase(collection, Nil).to_result
    #     erase_count_fst = StoreFSTActionBuilder.erase(collection, Nil).to_result
    #
    #     return Ok(erase_count_kv) if erase_count_kv.is_ok? && erase_count_fst.is_ok?
    #   end
    #
    #   Err(Nil)
    # end
  end
end
