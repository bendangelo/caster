module Executer
  class Push
    def self.execute(item : Store::Item, token : Lexer::Token, attrs : Array(UInt16)?)
      # general_kv_access_lock_read!
      # general_fst_access_lock_read!

      collection, bucket, object = item.collection, item.bucket, item.object

      if bucket.nil?
        Log.error { "bucket is nil" }
        return
      end
      if object.nil?
        Log.error { "object is nil" }
        return
      end

      # if let (Ok(kv_store), Ok(fst_store)) = (
      kv_store = Store::KVPool.acquire(Store::KVAcquireMode::Any, collection)
      #   StoreFSTPool.acquire(collection, bucket)
      # )
      # executor_kv_lock_write!(kv_store)

      kv_action = Store::KVAction.new(bucket: bucket, store: kv_store)
      # fst_action = StoreFSTActionBuilder.access(fst_store)

      # Try to resolve existing OID to IID, otherwise initialize IID (store the
      #   bi-directional relationship)
      oid = object
      iid = kv_action.get_oid_to_iid(oid) do |store_key|
        Log.info { "must initialize push executor oid-to-iid and iid-to-oid" }

        iid_incr = kv_action.get_meta_to_value(Store::IIDIncr)
        iid_incr = (iid_incr.nil? ? 0_u32 : iid_incr.to_u32) + 1

        kv_action.set_meta_to_value(Store::IIDIncr, iid_incr)
        kv_action.set_oid_to_iid(oid, iid_incr)
        kv_action.set_iid_to_oid(iid_incr, oid)

        iid_incr
      end

      return if iid.nil?

      has_commits = false
      terms = kv_action.get_iid_to_terms(iid)
      if terms.nil?
        terms = Set(UInt32).new
      end

      if !attrs.nil?
        kv_action.set_iid_to_attrs(iid, attrs)
      end

      Log.info { "got push executor stored iid-to-terms: #{terms}" }

      token.parse_text do |term, term_hashed, index|
        if terms.add?(term_hashed)
          iids = kv_action.get_term_to_iids(term_hashed, index)
          iids = iids.nil? ? Set(UInt32).new : iids

          has_commits = true

          next if !iids.add?(iid)

          Log.info { "has push executor term-to-iids: #{iid}" }

          # truncate_limit = APP_CONF.store.kv.retain_word_objects
          #
          # if iids.size > truncate_limit
          #   Log.info { "push executor term-to-iids object too long (limit: #{truncate_limit})" }
          #   term_iids_drain = iids.pop(truncate_limit)
          #   executor_ensure_op!(kv_action.batch_truncate_object(term_hashed, term_iids_drain))
          # end

          kv_action.set_term_to_iids(term_hashed, iids, index)

        end

        # if fst_action.push_word(term)
        #   Log.debug { "push term committed to graph: #{term}" }
        # end
      end

      if has_commits

        Log.info { "has push executor iid-to-terms commits: #{terms}" }

        kv_action.set_iid_to_terms(iid, terms)
      end

    end

  end
end
