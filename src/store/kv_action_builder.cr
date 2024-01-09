module Store

  class KVActionBuilder

    def self.proceed_erase_collection(collection_str : String) : Result(UInt32, Nil)
      collection_atom = KeyerHasher.to_compact(collection_str)
      collection_path = KVBuilder.path(collection_atom)

      # Force a KV store close
      StoreKVBuilder.close(collection_atom)

      if collection_path.exists?
        debug "kv collection store exists, erasing: #{collection_str}/* at path: #{collection_path}"

        # Remove KV store storage from filesystem
        erase_result = Dir.remove(collection_path)

        if erase_result
          debug "done with kv collection erasure"
          Ok(1)
        else
          Err(Nil)
        end
      else
        debug "kv collection store does not exist, consider already erased: #{collection_str}/* at path: #{collection_path}"

        Ok(0)
      end
    end

    def self.proceed_erase_bucket(_collection : String, _bucket : String) : Result(UInt32, Nil)
      # This one is not implemented, as we need to acquire the collection;
      # which would cause a party-killer dead-lock.
      Err(Nil)
    end
  end
end
