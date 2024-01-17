module Store

  class KVActionBuilder

    def self.erase(collection)

      if store = KVPool.find? collection
        Log.debug { "kv collection store exists, erasing: #{collection}/* at path: #{store.path}" }

        # Force a KV store close
        if !KVPool.close(collection)
          Log.error { "closing kvstore failed" }
          return 0
        end

        # Remove KV store storage from filesystem
        erase_result = FileUtils.rm_rf(store.path)

        Log.debug { "done with kv collection erasure" }

        return 1
      else

        Log.debug { "no kv collection store exists for #{collection}" }

        return 0
      end
    end

  end
end
