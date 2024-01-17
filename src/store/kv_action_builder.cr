module Store

  class KVActionBuilder

    def self.erase(collection)

      path = KVBuilder.path collection

      Log.debug { "erasing: #{collection}/* at path: #{path}" }

      if store = KVPool.find? collection
        Log.debug { "kv collection store exists, will close." }

        # Force a KV store close
        if !KVPool.close(collection)
          Log.error { "closing kvstore failed" }
          return 0
        end
      end

      # Remove KV store storage from filesystem
      if Dir.exists? path
        erase_result = FileUtils.rm_rf(path)

        Log.debug { "done with kv collection erasure" }

        return 1
      else
        Log.debug { "kv erase #{path} not found" }
        return 0
      end
    end

  end
end
