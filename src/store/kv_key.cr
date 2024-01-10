module Store

  module KVKey

    def self.from_str(collection_str) : UInt32
      Store::Hasher.to_compact collection_str
    end

  end
end
