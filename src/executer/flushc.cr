module Executer
  class FlushC
    def self.execute(item : Store::Item)
      collection = item.collection

      if collection
        # general_kv_access_lock_write!
        # general_fst_access_lock_write!

        erase_count_kv = Store::KVActionBuilder.erase(collection)
        # erase_count_fst = StoreFSTActionBuilder.erase(collection, Nil).to_result

        return erase_count_kv
      end

      nil
    end
  end
end
