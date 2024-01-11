module Executer
  class Search
    def self.execute(store : StoreItem, event_id : String, lexer : TokenLexer, limit : UInt32, offset : UInt32)
  #     store = StoreItem.new(collection, bucket)
  #
  #     # general_kv_access_lock_read!
  #     # general_fst_access_lock_read!
  #
  #     Store::KVPool.acquire(StoreKVAcquireMode::OpenOnly, collection)
  #       # StoreFSTPool.acquire(collection, bucket)
  #     # executor_kv_lock_read!(kv_store)
  #
  #     kv_action = Store::KVActionBuilder.access(bucket, kv_store)
  #     # fst_action = StoreFSTActionBuilder.access(fst_store)
  #
  #     found_iids = Set(UInt32).new
  #
  #     lexer.each do |term, term_hashed|
  #       iids = kv_action.get_term_to_iids(term_hashed)
  #
  #       higher_limit = APP_CONF.store.kv.retain_word_objects
  #       alternates_try = APP_CONF.channel.search.query_alternates_try
  #
  #       if iids.size < higher_limit && alternates_try > 0
  #         Log.debug { "not enough iids were found (#{iids.size}/#{higher_limit}), completing for term: #{term}" }
  #
  #         if let Some(suggested_words) = fst_action.suggest_words(term, alternates_try + 1, 1)
  #           iids_new_len = iids.size
  #
  #           suggested_words.each do |suggested_word|
  #             next if suggested_word == term
  #
  #             Log.debug { "got completed word: #{suggested_word} for term: #{term}" }
  #
  #             if let Some(suggested_iids) = kv_action.get_term_to_iids(StoreTermHash.new(suggested_word)).unwrap_or(nil)
  #               suggested_iids.each do |suggested_iid|
  #                 unless iids.include?(suggested_iid)
  #                   iids << suggested_iid
  #                   iids_new_len += 1
  #
  #                   if iids_new_len >= higher_limit
  #                     Log.debug { "got enough completed results for term: #{term}" }
  #                     break
  #                   end
  #                 end
  #               end
  #             end
  #           end
  #
  #           Log.debug { "done completing results for term: #{term}, now #{iids_new_len} results" }
  #         else
  #           Log.debug { "did not get any completed word for term: #{term}" }
  #           end
  #       end
  #
  #       Log.debug { "got search executor iids: #{iids} for term: #{term}" }
  #
  #       if found_iids.empty?
  #         found_iids = iids
  #       else
  #         found_iids = found_iids.intersection(iids).to_a
  #       end
  #
  #       Log.debug { "got search executor iid intersection: #{found_iids} for term: #{term}" }
  #
  #       if found_iids.empty?
  #         info "stop search executor as no iid was found in common for term: #{term}"
  #         break
  #       end
  #     end
  #
  #     limit_usize = limit.to_i
  #     offset_usize = offset.to_i
  #     result_oids = [] of String
  #
  #     found_iids.drop(offset_usize).each_with_index do |found_iid, index|
  #       break if index >= limit_usize
  #
  #       if let Some(oid) = kv_action.get_iid_to_oid(found_iid)
  #         result_oids << oid
  #       else
  #         error "failed getting search executor iid-to-oid"
  #       end
  #     end
  #
  #     info "got search executor final oids: #{result_oids}"
  #
  #     return if result_oids.empty?
  #     return Some(result_oids)
  #     end
  #   end
  #
  #   nil
  end
end
end
