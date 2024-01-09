module Store
  class StoreKVAction
    #   include StoreGenericAction
    #   alias StoreKeyerKey = Tuple(UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    #   alias StoreKeyerPrefix = Tuple(UInt8, UInt8, UInt8, UInt8, UInt8)
    #   alias StoreKeyerHashedTerms = Array(StoreTermHashed)
    #   alias Drain = Array(StoreObjectIID)
    #
    #   # Meta-to-Value mapper
    #   #
    #   # [IDX=0] ((meta)) ~> ((value))
    #   def get_meta_to_value(meta : StoreMetaKey) : Result(StoreMetaValue?, Nil)
    #     if store?
    #       store_key = StoreKeyerBuilder.meta_to_value(@bucket.as_str, meta)
    #
    #       debug "store get meta-to-value: #{store_key}"
    #
    #       case store.get(store_key.as_bytes)
    #       when .ok?(value)
    #         debug "got meta-to-value: #{store_key}"
    #
    #         value_str = String.new(value)
    #
    #         case meta
    #         when StoreMetaKey::IIDIncr
    #           iid_incr = value_str.to_i32
    #           iid_incr > 0 ? Ok(StoreMetaValue::IIDIncr(iid_incr.to_u32)) : Nil
    #         else
    #           Nil
    #         end
    #       when .ok?(nil)
    #         debug "no meta-to-value found: #{store_key}"
    #         Ok(nil)
    #       when .err(err)
    #         error "error getting meta-to-value: #{store_key} with trace: #{err}"
    #         Nil
    #       end
    #     else
    #       Ok(nil)
    #     end
    #   end
    #
    #   def set_meta_to_value(meta : StoreMetaKey, value : StoreMetaValue) : Result(Nil, Nil)
    #     if store?
    #       store_key = StoreKeyerBuilder.meta_to_value(@bucket.as_str, meta)
    #
    #       debug "store set meta-to-value: #{store_key}"
    #
    #       value_str = case value
    #                   when StoreMetaValue::IIDIncr(iid_incr)
    #                     iid_incr.to_s
    #                   else
    #                     ""
    #                   end
    #
    #       store.put(store_key.as_bytes, value_str.as_bytes).as(Result(Nil, Nil))
    #     else
    #       Nil
    #     end
    #   end
    #
    #   # Term-to-IIDs mapper
    #   #
    #   # [IDX=1] ((term)) ~> [((iid))]
    #   def get_term_to_iids(term_hashed : StoreTermHashed) : Result(StoreObjectIID?, Nil)
    #     if store?
    #       store_key = StoreKeyerBuilder.term_to_iids(@bucket.as_str, term_hashed)
    #
    #       debug "store get term-to-iids: #{store_key}"
    #
    #       case store.get(store_key.as_bytes)
    #       when .ok?(value)
    #         debug "got term-to-iids: #{store_key} with encoded value: #{value.to_s}"
    #
    #         decoded_iids = decode_u32_list(value.to_s)
    #
    #         if decoded_iids
    #           debug "got term-to-iids: #{store_key} with decoded value: #{decoded_iids}"
    #           Ok(decoded_iids)
    #         else
    #           Nil
    #         end
    #       when .ok?(nil)
    #         debug "no term-to-iids found: #{store_key}"
    #         Ok(nil)
    #       when .err(err)
    #         error "error getting term-to-iids: #{store_key} with trace: #{err}"
    #         Nil
    #       end
    #     else
    #       Ok(nil)
    #     end
    #   end
    #
    #   def set_term_to_iids(term_hashed : StoreTermHashed, iids : Array(StoreObjectIID)) : Result(Nil, Nil)
    #     if store?
    #       store_key = StoreKeyerBuilder.term_to_iids(@bucket.as_str, term_hashed)
    #
    #       debug "store set term-to-iids: #{store_key}"
    #
    #       iids_encoded = encode_u32_list(iids)
    #
    #       debug "store set term-to-iids: #{store_key} with encoded value: #{iids_encoded}"
    #
    #       store.put(store_key.as_bytes, iids_encoded.as_slice).as(Result(Nil, Nil))
    #     else
    #       Nil
    #     end
    #   end
    #
    #   def delete_term_to_iids(term_hashed : StoreTermHashed) : Result(Nil, Nil)
    #     if store?
    #       store_key = StoreKeyerBuilder.term_to_iids(@bucket.as_str, term_hashed)
    #
    #       debug "store delete term-to-iids: #{store_key}"
    #
    #       store.delete(store_key.as_bytes).as(Result(Nil, Nil))
    #     else
    #       Nil
    #     end
    #   end
    #
    #   # OID-to-IID mapper
    #   #
    #   # [IDX=2] ((oid)) ~> ((iid))
    #   def get_oid_to_iid(oid : StoreObjectOID) : Result(StoreObjectIID?, Nil)
    #     if store?
    #       store_key = StoreKeyerBuilder.oid_to_iid(@bucket.as_str, oid)
    #
    #       debug "store get oid-to-iid: #{store_key}"
    #
    #       case store.get(store_key.as_bytes)
    #       when .ok?(value)
    #         debug "got oid-to-iid: #{store_key} with encoded value: #{value.to_s}"
    #
    #         decoded_iid = decode_u32(value.to_s)
    #
    #         if decoded_iid
    #           debug "got oid-to-iid: #{store_key} with decoded value: #{decoded_iid}"
    #           Ok(decoded_iid)
    #         else
    #           Nil
    #         end
    #       when .ok?(nil)
    #         debug "no oid-to-iid found: #{store_key}"
    #         Ok(nil)
    #       when .err(err)
    #         error "error getting oid-to-iid: #{store_key} with trace: #{err}"
    #         Nil
    #       end
    #     else
    #       Ok(nil)
    #     end
    #   end
    #
    #   def set_oid_to_iid(oid : StoreObjectOID, iid : StoreObjectIID) : Result(Nil, Nil)
    #     if store?
    #       store_key = StoreKeyerBuilder.oid_to_iid(@bucket.as_str, oid)
    #
    #       debug "store set oid-to-iid: #{store_key}"
    #
    #       iid_encoded = encode_u32(iid)
    #
    #       debug "store set oid-to-iid: #{store_key} with encoded value: #{iid_encoded}"
    #
    #       store.put(store_key.as_bytes, iid_encoded.as_slice).as(Result(Nil, Nil))
    #     else
    #       Nil
    #     end
    #   end
    #
    #   def delete_oid_to_iid(oid : StoreObjectOID) : Result(Nil, Nil)
    #     if store?
    #       store_key = StoreKeyerBuilder.oid_to_iid(@bucket.as_str, oid)
    #
    #       debug "store delete oid-to-iid: #{store_key}"
    #
    #       store.delete(store_key.as_bytes).as(Result(Nil, Nil))
    #     else
    #       Nil
    #     end
    #   end
    #   # IID-to-OID mapper
    #   #
    #   # [IDX=3] ((iid)) ~> ((oid))
    #   def get_iid_to_oid(iid : StoreObjectIID) : ResultType?
    #     if store?
    #       store_key = StoreKeyerBuilder.iid_to_oid(@bucket.as_str, iid)
    #
    #       debug "store get iid-to-oid: #{store_key}"
    #
    #       case store.get(store_key.as_bytes)
    #       when .ok?(value)
    #         decoded_value = String.new(value).to_s
    #         Ok(ResultType.new(decoded_value, 0))
    #       when .ok?(nil)
    #         Ok(nil)
    #       when .err(err)
    #         error "error getting iid-to-oid: #{store_key} with trace: #{err}"
    #         Nil
    #       end
    #     else
    #       Ok(nil)
    #     end
    #   end
    #
    #   def set_iid_to_oid(iid : StoreObjectIID, oid : StoreObjectOID) : Result(Nil, Nil)
    #     if store?
    #       store_key = StoreKeyerBuilder.iid_to_oid(@bucket.as_str, iid)
    #
    #       debug "store set iid-to-oid: #{store_key}"
    #
    #       store.put(store_key.as_bytes, oid.as_bytes).as(Result(Nil, Nil))
    #     else
    #       Nil
    #     end
    #   end
    #
    #   def delete_iid_to_oid(iid : StoreObjectIID) : Result(Nil, Nil)
    #     if store?
    #       store_key = StoreKeyerBuilder.iid_to_oid(@bucket.as_str, iid)
    #
    #       debug "store delete iid-to-oid: #{store_key}"
    #
    #       store.delete(store_key.as_bytes).as(Result(Nil, Nil))
    #     else
    #       Nil
    #     end
    #   end
    #
    #   # IID-to-Terms mapper
    #   #
    #   # [IDX=4] ((iid)) ~> [((term))]
    #   def get_iid_to_terms(iid : StoreObjectIID) : ResultTypeList?
    #     if store?
    #       store_key = StoreKeyerBuilder.iid_to_terms(@bucket.as_str, iid)
    #
    #       debug "store get iid-to-terms: #{store_key}"
    #
    #       case store.get(store_key.as_bytes)
    #       when .ok?(value)
    #         decoded_value = decode_u32_list(value.to_s)
    #
    #         if decoded_value
    #           debug "got iid-to-terms: #{store_key} with decoded value: #{decoded_value}"
    #           terms = decoded_value.map { |term| StoreTermHashed.new(term) }
    #           Ok(terms)
    #         else
    #           Nil
    #         end
    #       when .ok?(nil)
    #         Ok(nil)
    #       when .err(err)
    #         error "error getting iid-to-terms: #{store_key} with trace: #{err}"
    #         Nil
    #       end
    #     else
    #       Ok(nil)
    #     end
    #   end
    #
    #   def set_iid_to_terms(iid : StoreObjectIID, terms_hashed : StoreKeyerHashedTerms) : Result(Nil, Nil)
    #     if store?
    #       store_key = StoreKeyerBuilder.iid_to_terms(@bucket.as_str, iid)
    #
    #       debug "store set iid-to-terms: #{store_key}"
    #
    #       terms_hashed_encoded = encode_u32_list(terms_hashed.map { |term| term.to_i32 })
    #
    #       debug "store set iid-to-terms: #{store_key} with encoded value: #{terms_hashed_encoded}"
    #
    #       store.put(store_key.as_bytes, terms_hashed_encoded.as_slice).as(Result(Nil, Nil))
    #     else
    #       Nil
    #     end
    #   end
    #
    #   def delete_iid_to_terms(iid : StoreObjectIID) : Result(Nil, Nil)
    #     if store?
    #       store_key = StoreKeyerBuilder.iid_to_terms(@bucket.as_str, iid)
    #
    #       debug "store delete iid-to-terms: #{store_key}"
    #
    #       store.delete(store_key.as_bytes).as(Result(Nil, Nil))
    #     else
    #       Nil
    #     end
    #   end
    #
    #   def batch_flush_bucket(iid : StoreObjectIID, oid : StoreObjectOID, iid_terms_hashed : StoreKeyerHashedTerms) : Result(UInt32, Nil)
    #     count = 0
    #
    #     debug "store batch flush bucket: #{iid} with hashed terms: #{iid_terms_hashed}"
    #
    #     # Delete OID <> IID association
    #     case store.delete_oid_to_iid(oid), store.delete_iid_to_oid(iid), store.delete_iid_to_terms(iid)
    #     when Ok(_), Ok(_), Ok(_)
    #       # Delete IID from each associated term
    #       for iid_term in iid_terms_hashed
    #       if term_iid_iids = store.get_term_to_iids(iid_term)
    #         if term_iid_iids.includes?(iid)
    #           count += 1
    #
    #           # Remove IID from list of IIDs
    #           term_iid_iids.retain { |cur_iid| cur_iid != iid }
    #
    #           is_ok = if term_iid_iids.empty?
    #                     store.delete_term_to_iids(iid_term).is_ok
    #                   else
    #                     store.set_term_to_iids(iid_term, term_iid_iids).is_ok
    #                   end
    #
    #           if !is_ok
    #             return Err(Nil)
    #           end
    #         end
    #       end
    #     end
    #
    #     Ok(count)
    #   else
    #     Err(Nil)
    #   end
    # end
    #
    # def batch_truncate_object(term_hashed : StoreTermHashed, term_iids_drain : Drain(StoreObjectIID)) : Result(UInt32, Nil)
    #   count = 0
    #
    #   term_iids_drain.each do |term_iid_drain|
    #     debug "store batch truncate object iid: #{term_iid_drain}"
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
    #           error "failed executing store batch truncate object batch-flush-bucket"
    #           end
    #         else
    #           error "failed getting store batch truncate object iid-to-oid"
    #         end
    #       else
    #         # Update IID to Terms list
    #         if store.set_iid_to_terms(term_iid_drain, term_iid_drain_terms).is_err?
    #           error "failed setting store batch truncate object iid-to-terms"
    #         end
    #       end
    #     end
    #   end
    #
    #   Ok(count)
    # end
    #
    # def batch_erase_bucket : Result(UInt32, Nil)
    #   if (store?)
    #     # Generate all key prefix values (with dummy post-prefix values; we dont care)
    #     key_meta_to_value = StoreKeyerBuilder.meta_to_value(@bucket.as_str, StoreMetaKey::IIDIncr)
    #     key_term_to_iids = StoreKeyerBuilder.term_to_iids(@bucket.as_str, 0)
    #     key_oid_to_iid = StoreKeyerBuilder.oid_to_iid(@bucket.as_str, "")
    #     key_iid_to_oid = StoreKeyerBuilder.iid_to_oid(@bucket.as_str, 0)
    #     key_iid_to_terms = StoreKeyerBuilder.iid_to_terms(@bucket.as_str, 0)
    #
    #     key_prefixes = [
    #       key_meta_to_value.as_prefix,
    #       key_term_to_iids.as_prefix,
    #       key_oid_to_iid.as_prefix,
    #       key_iid_to_oid.as_prefix,
    #       key_iid_to_terms.as_prefix
    #     ]
    #
    #     # Scan all keys per-prefix and nuke them right away
    #     key_prefixes.each do |key_prefix|
    #       debug "store batch erase bucket: #{@bucket.as_str} for prefix: #{key_prefix}"
    #
    #       # Generate start and end prefix for batch delete (in other words, the minimum
    #       #   key value possible, and the highest key value possible)
    #       key_prefix_start = [key_prefix[0], key_prefix[1], key_prefix[2], key_prefix[3], key_prefix[4], 0, 0, 0, 0]
    #       key_prefix_end = [key_prefix[0], key_prefix[1], key_prefix[2], key_prefix[3], key_prefix[4], 255, 255, 255, 255]
    #
    #       # Batch-delete keys matching range
    #       batch = WriteBatch.new
    #
    #       batch.delete_range(key_prefix_start, key_prefix_end)
    #
    #       # Commit operation to database
    #       store.do_write(batch).to(Result(UInt32, Nil)) do |err|
    #         error "failed in store batch erase bucket: #{@bucket.as_str} with error: #{err}"
    #       else
    #         # Ensure last key is deleted (as RocksDB end key is exclusive; while
    #         #   start key is inclusive, we need to ensure the end-of-range key is
    #         #   deleted)
    #         store.delete(key_prefix_end).ok
    #
    #         debug "succeeded in store batch erase bucket: #{@bucket.as_str}"
    #         end
    #     end
    #
    #     info "done processing store batch erase bucket: #{@bucket.as_str}"
    #
    #     Ok(1)
    #   else
    #     Err(Nil)
    #   end
    # end
    #
    # def self.encode_u32(decoded : UInt32) : Bytes
    #   encoded = Bytes.new(4)
    #   IO::ByteFormat::LE.encode(encoded, decoded)
    #   encoded
    # end
    #
    # def self.decode_u32(encoded : Bytes) : Result(UInt32, Nil)
    #   cursor = IO::Memory.new(encoded)
    #   value = cursor.read(UInt32).to_unsafe.result
    #   value.nil? ? Err(Nil) : Ok(value)
    # end
    #
    # def self.encode_u32_list(decoded : Array(UInt32)) : Bytes
    #   encoded = Bytes.new(decoded.size * 4)
    #
    #   decoded.each do |decoded_item|
    #     encoded << encode_u32(decoded_item)
    #   end
    #
    #   encoded
    # end
    #
    # def self.decode_u32_list(encoded : Bytes) : Result(Array(UInt32), Nil)
    #   decoded = Array(UInt32).new(encoded.size / 4)
    #
    #   encoded.each_slice(4) do |encoded_chunk|
    #     if let Ok(decoded_chunk) = decode_u32(encoded_chunk)
    #       decoded << decoded_chunk
    #     else
    #       return Err(Nil)
    #     end
    #   end
    #
    #   Ok(decoded)
    # end
  end
end
