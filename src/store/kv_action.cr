module Store

  alias MetaKey = UInt32
  alias TermHash = UInt32
  IIDIncr = 0_u32

  struct KVAction
    property bucket : String
    property store : KVStore

    def initialize(@bucket : String, @store : KVStore)
    end

    # Meta-to-Value mapper
    #
    # [IDX=0] ((meta)) ~> ((value))
    def get_meta_to_value(meta : MetaKey)
      if store
        store_key = Keyer.meta_to_value(@bucket, meta)

        Log.debug { "store get meta-to-value: #{store_key}" }

        if value = store.get?(store_key.as_bytes)
          Log.debug { "got meta-to-value: #{store_key}" }

          KVAction.decode_u32 value
        else
          Log.debug { "no meta-to-value found: #{store_key}" }
          nil
        end
      else
        nil
      end
    end

    def set_meta_to_value(meta : MetaKey, value : UInt32)
      if store
        store_key = Keyer.meta_to_value(@bucket, meta)

        Log.debug { "store set meta-to-value: #{store_key}" }

        encoded = KVAction.encode_u32 value

        store.put(store_key.as_bytes, encoded)
      else
        raise "Store not defined"
      end
    end

    # Term-to-IIDs mapper
    #
    # [IDX=1] ((term)) ~> [((iid))]
    def get_term_to_iids(term_hashed : TermHash, index : UInt8 = 0)
      if store
        store_key = Keyer.term_to_iids(@bucket, term_hashed, index)

        Log.debug { "store get term-to-iids: #{store_key}" }

        if value = store.get?(store_key.as_bytes)
          Log.debug { "got term-to-iids: #{store_key} with encoded value: #{value}" }

          decoded_iids = KVAction.decode_u32_set(value)

          if decoded_iids
            Log.debug { "got term-to-iids: #{store_key} with decoded value: #{decoded_iids}" }
            decoded_iids
          else
            nil
          end
        else
          Log.debug { "no term-to-iids found: #{store_key}" }
          nil
        end
      else
        nil
      end
    end

    def iterate_term_to_iids(term_hashed : TermHash, start_index : UInt8 = 0, length = MAX_TERM_INDEX_SIZE)

      length = MAX_TERM_INDEX_SIZE if length > Store::MAX_TERM_INDEX_SIZE

      Log.debug { "store iterate term-to-iids: #{term_hashed} #{start_index}" }

      start_index.upto(length) do |i|

        # store.iterate_over_prefix(key_prefix) do |key, value|
        iids = get_term_to_iids(term_hashed, i.to_u8)
        if iids
          yield iids, i
        end
      end
      #
      # store_key = Keyer.term_to_iids(@bucket, term_hashed, start_index)
      #
      # # store.iterate_over_prefix(key_prefix) do |key, value|
      #   decoded_iids = KVAction.decode_u32_set(value)
      #   if decoded_iids
      #     Log.debug { "got term-to-iids: #{store_key} with decoded value: #{decoded_iids}" }
      #     yield decoded_iids
      #   end
      # # end

      # if value = store.get?(store_key.as_bytes)
      #   Log.debug { "iterate term-to-iids: #{store_key} with encoded value: #{value}" }
      #
      #   decoded_iids = KVAction.decode_u32_set(value)
      #
      #   if decoded_iids
      #     Log.debug { "got term-to-iids: #{store_key} with decoded value: #{decoded_iids}" }
      #     decoded_iids
      #   else
      #     nil
      #   end
      # else
      #   Log.debug { "no term-to-iids found: #{store_key}" }
      #   nil
      # end
    end

    def add_term_to_iids?(term_hashed : TermHash, iid : UInt32, index : UInt8 = 0)
      if store
        store_key = Keyer.term_to_iids(@bucket, term_hashed, index)

        Log.debug { "store set term-to-iids: #{store_key}" }

        iids = get_term_to_iids(term_hashed, index) || Set(UInt32).new

        if iids.add? iid
          iids_encoded = KVAction.encode_u32_set(iids)

          Log.debug { "store set term-to-iids: #{store_key} with encoded value: #{iids_encoded}" }

          store.put(store_key.as_bytes, iids_encoded)
          true
        else
          false
        end
      else
        false
      end
    end

    def set_term_to_iids(term_hashed : TermHash, iids : Set(UInt32), index : UInt8 = 0)
      if store
        store_key = Keyer.term_to_iids(@bucket, term_hashed, index)

        Log.debug { "store set term-to-iids: #{store_key}" }

        iids_encoded = KVAction.encode_u32_set(iids)

        Log.debug { "store set term-to-iids: #{store_key} with encoded value: #{iids_encoded}" }

        store.put(store_key.as_bytes, iids_encoded)
      else
        nil
      end
    end

    def delete_term_to_iids(term_hashed : TermHash, index : UInt8 = 0)
      if store
        store_key = Keyer.term_to_iids(@bucket, term_hashed, index)

        Log.debug { "store delete term-to-iids: #{store_key}" }

        store.delete(store_key.as_bytes)
      else
        nil
      end
    end

    # OID-to-IID mapper
    #
    # [IDX=2] ((oid)) ~> ((iid))
    def get_oid_to_iid(oid : String)
      if store
        store_key = Keyer.oid_to_iid(@bucket, oid)

        Log.debug { "store get oid-to-iid: #{store_key}" }

        if value = store.get?(store_key.as_bytes)
          Log.debug { "got oid-to-iid: #{store_key} with encoded value: #{value}" }

          decoded_iid = KVAction.decode_u32(value)

          Log.debug { "got oid-to-iid: #{store_key} with decoded value: #{decoded_iid}" }
          decoded_iid
        else
          Log.debug { "no oid-to-iid found: #{store_key}" }
          yield store_key
        end
      else
        nil
      end
    end

    def get_oid_to_iid(oid : String)
      get_oid_to_iid oid do
        nil
      end
    end

    def set_oid_to_iid(oid : String, iid : UInt32)
      if store
        store_key = Keyer.oid_to_iid(@bucket, oid)

        Log.debug { "store set oid-to-iid: #{store_key}" }

        iid_encoded = KVAction.encode_u32(iid)

        Log.debug { "store set oid-to-iid: #{store_key} with encoded value: #{iid_encoded}" }

        store.put(store_key.as_bytes, iid_encoded)
      else
        raise "Store is nil"
      end
    end

    def delete_oid_to_iid(oid : String)
      if store
        store_key = Keyer.oid_to_iid(@bucket, oid)

        Log.debug { "store delete oid-to-iid: #{store_key}" }

        store.delete(store_key.as_bytes)
      else
        nil
      end
    end

    # IID-to-OID mapper
    #
    # [IDX=3] ((iid)) ~> ((oid))
    def get_iid_to_oid(iid : UInt32)
      if store
        store_key = Keyer.iid_to_oid(@bucket, iid)

        Log.debug { "store get iid-to-oid: #{store_key}" }

        if value = store.get?(store_key.as_bytes)
          String.new(value)
        else
          Log.debug { "not found, getting iid-to-oid: #{store_key}" }
          nil
        end
      else
        nil
      end
    end

    def set_iid_to_oid(iid : UInt32, oid : String)
      if store
        store_key = Keyer.iid_to_oid(@bucket, iid)

        Log.debug { "store set iid-to-oid: #{store_key}" }

        store.put(store_key.as_bytes, oid.to_slice)
      else
        raise "Store is nil"
      end
    end

    def delete_iid_to_oid(iid : UInt32)
      if store
        store_key = Keyer.iid_to_oid(@bucket, iid)

        Log.debug { "store delete iid-to-oid: #{store_key}" }

        store.delete(store_key.as_bytes)
        true
      else
        nil
      end
    end

    # IID-to-Terms mapper
    #
    # [IDX=4] ((iid)) ~> [((term))]
    def get_iid_to_terms(iid : UInt32)
      if store
        store_key = Keyer.iid_to_terms(@bucket, iid)

        Log.debug { "store get iid-to-terms: #{store_key}" }

        if value = store.get?(store_key.as_bytes)
          decoded_value = KVAction.decode_u32_set(value)

          Log.debug { "got iid-to-terms: #{store_key} with decoded value: #{decoded_value}" }
          decoded_value
        else
          nil
        end
      else
        nil
      end
    end

    def set_iid_to_terms(iid : UInt32, terms_hashed : Set(UInt32))
      if store
        store_key = Keyer.iid_to_terms(@bucket, iid)

        Log.debug { "store set iid-to-terms: #{store_key}" }

        terms_hashed_encoded = KVAction.encode_u32_set(terms_hashed)

        Log.debug { "store set iid-to-terms: #{store_key} with encoded value: #{terms_hashed_encoded}" }

        store.put(store_key.as_bytes, terms_hashed_encoded)
      else
        nil
      end
    end

    def delete_iid_to_terms(iid : UInt32)
      if store
        store_key = Keyer.iid_to_terms(@bucket, iid)

        Log.debug { "store delete iid-to-terms: #{store_key}" }

        store.delete(store_key.as_bytes)
      else
        nil
      end
    end

    # IID-to-Attrs mapper
    #
    # [IDX=5] ((iid)) ~> [((attr))]
    def get_iid_to_attrs(iid : UInt32)
      if store
        store_key = Keyer.iid_to_attrs(@bucket, iid)

        Log.debug { "store get iid-to-attrs: #{store_key}" }

        if value = store.get?(store_key.as_bytes)
          decoded_value = KVAction.decode_u32_array(value)

          Log.debug { "got iid-to-attrs: #{store_key} with decoded value: #{decoded_value}" }
          decoded_value
        else
          nil
        end
      else
        nil
      end
    end

    def set_iid_to_attrs(iid : UInt32, attrs : Array(UInt32))
      if store
        store_key = Keyer.iid_to_attrs(@bucket, iid)

        Log.debug { "store set iid-to-attrs: #{store_key}" }

        terms_hashed_encoded = KVAction.encode_u32_array(attrs)

        Log.debug { "store set iid-to-attrs: #{store_key} with encoded value: #{terms_hashed_encoded}" }

        store.put(store_key.as_bytes, terms_hashed_encoded)
      else
        nil
      end
    end

    def delete_iid_to_attrs(iid : UInt32)
      if store
        store_key = Keyer.iid_to_attrs(@bucket, iid)

        Log.debug { "store delete iid-to-attrs: #{store_key}" }

        store.delete(store_key.as_bytes)
      else
        nil
      end
    end

    def batch_flush_bucket(iid : UInt32, oid : String, iid_terms_hashed : Set(UInt32))
      count = 0

      Log.debug { "store batch flush bucket: #{iid} with hashed terms: #{iid_terms_hashed}" }

      # Delete OID <> IID association
      if delete_oid_to_iid(oid) && delete_iid_to_oid(iid) && delete_iid_to_terms(iid)

        # are optional
        delete_iid_to_attrs(iid)

        # Delete IID from each associated term
        iid_terms_hashed.each do |iid_term|
          iterate_term_to_iids(iid_term) do |iids, index|
            if iids.includes?(iid)
              count += 1

              # Remove IID from list of IIDs
              iids.delete(iid)

              if iids.empty?
                delete_term_to_iids(iid_term, index)
              else
                set_term_to_iids(iid_term, iids, index)
              end

            end
          end
        end
      end

      count
    end

    # def batch_truncate_object(term_hashed : TermHash, term_iids_drain : Drain(UInt32)) : Result(UInt32, nil)
    #   count = 0
    #
    #   term_iids_drain.each do |term_iid_drain|
    #     Log.debug { "store batch truncate object iid: #{term_iid_drain}" }
    #
    #     # Nuke term in IID to Terms list
    #     if term_iid_drain_terms = store.get_iid_to_terms(term_iid_drain)
    #       count += 1
    #
    #       term_iid_drain_terms.retain { |cur_term| cur_term != term_hashed }
    #
    #       # IID to Terms list is empty? Flush whole object.
    #       if term_iid_drain_terms.empty?
    #         # Acquire OID for this drained IID
    #         if term_iid_drain_oid = store.get_iid_to_oid(term_iid_drain)
    #           if store.batch_flush_bucket(term_iid_drain, term_iid_drain_oid, [])
    #             .is_err?
    #           Log.error { "failed executing store batch truncate object batch-flush-bucket" }
    #           end
    #         else
    #           Log.error { "failed getting store batch truncate object iid-to-oid" }
    #         end
    #       else
    #         # Update IID to Terms list
    #         if store.set_iid_to_terms(term_iid_drain, term_iid_drain_terms).is_err?
    #           Log.error { "failed setting store batch truncate object iid-to-terms" }
    #         end
    #       end
    #     end
    #   end
    #
    #   Ok(count)
    # end

    def batch_erase_bucket
      # Generate all key prefix values (with dummy post-prefix values; we dont care)
      key_meta_to_value = Keyer.meta_to_value(@bucket, IIDIncr)
      key_term_to_iids = Keyer.term_to_iids(@bucket, 0)
      key_oid_to_iid = Keyer.oid_to_iid(@bucket, "")
      key_iid_to_oid = Keyer.iid_to_oid(@bucket, 0)
      key_iid_to_terms = Keyer.iid_to_terms(@bucket, 0)

      key_prefixes = [
        key_meta_to_value.as_prefix,
        key_term_to_iids.as_prefix,
        key_oid_to_iid.as_prefix,
        key_iid_to_oid.as_prefix,
        key_iid_to_terms.as_prefix
      ]

      # Scan all keys per-prefix and nuke them right away
      key_prefixes.each do |key_prefix|
        Log.debug { "store batch erase bucket: #{@bucket} for prefix: #{key_prefix}" }

        # Generate start and end prefix for batch delete (in other words, the minimum
        #   key value possible, and the highest key value possible)
        key_prefix_start = Bytes[key_prefix[0], key_prefix[1], key_prefix[2], key_prefix[3], key_prefix[4], 0, 0, 0, 0]
        key_prefix_end = Bytes[key_prefix[0], key_prefix[1], key_prefix[2], key_prefix[3], key_prefix[4], 255, 255, 255, 255]

        # Batch-delete keys matching range
        batch = RocksDB::WriteBatch.new

        batch.delete_range(key_prefix_start, key_prefix_end)

        # Commit operation to database
        if err = store.write(batch)
          Log.error { "failed in store batch erase bucket: #{@bucket} with error: #{err}" }
          return err
        else
          # Ensure last key is deleted (as RocksDB end key is exclusive; while
          #   start key is inclusive, we need to ensure the end-of-range key is
          #   deleted)
          store.delete(key_prefix_end)

          Log.debug { "succeeded in store batch erase bucket: #{@bucket}" }
        end
      end

      Log.info { "done processing store batch erase bucket: #{@bucket}" }

    end

    def self.encode_u32(decoded : UInt32) : Bytes
      io = IO::Memory.new 4
      io.write_bytes(decoded, IO::ByteFormat::LittleEndian)
      io.to_slice
    end

    def self.decode_u32(encoded : Bytes)
      IO::ByteFormat::LittleEndian.decode(UInt32, encoded)
    end

    def self.encode_u32_set(decoded : Set(UInt32)) : Bytes
      io = IO::Memory.new(decoded.size * 4)

      decoded.each do |decoded_item|
        io.write_bytes(decoded_item, IO::ByteFormat::LittleEndian)
      end

      io.to_slice
    end

    def self.decode_u32_set(encoded : Bytes)
      decoded = Set(UInt32).new(encoded.size)

      encoded.each_with_index do |byte, i|
        if i % 4 == 0
          decoded << decode_u32(encoded[i, 4])
        end
      end

      decoded
    end

    def self.encode_u32_array(decoded : Array(UInt32)) : Bytes
      io = IO::Memory.new(decoded.size * 4)

      decoded.each do |decoded_item|
        io.write_bytes(decoded_item, IO::ByteFormat::LittleEndian)
      end

      io.to_slice
    end

    def self.decode_u32_array(encoded : Bytes)
      decoded = Array(UInt32).new(encoded.size)

      encoded.each_with_index do |byte, i|
        if i % 4 == 0
          decoded << IO::ByteFormat::LittleEndian.decode(UInt32, encoded[i, 4])
        end
      end

      decoded
    end
  end
end
