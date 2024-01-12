module Executer
  class Pop
    def self.execute(item : Store::Item, token : Lexar::Token)

      # TODO: add pop
      collection, bucket, object = item.collection, item.bucket, item.object

      if bucket.nil? || object.nil?
        Log.error { "bucket or object is nil" }
        return 0
      end

      count_popped = 0

      # general_kv_access_lock_read!
      # general_fst_access_lock_read!

      kv_store = Store::KVPool.acquire(Store::KVAcquireMode::Any, collection)

      kv_action = Store::KVAction.new(bucket: bucket, store: kv_store)
      # fst_action = StoreFSTActionBuilder.access(fst_store)

      oid = object

      # if iid = kv_action.get_oid_to_iid(oid)
      #
      #   if iid_terms = kv_action.get_iid_to_terms(iid)
      #     Log.info "got pop executor stored iid-to-terms: #{iid_terms}" }
      #
      #     pop_terms = token.collect
      #
      #     remaining_terms = iid_terms.difference(
      #       LinkedHashSet.new(pop_terms.map { |item| item[1] })
      #     ).to_a.to_set
      #
      #     Log.debug { "got pop executor terms remaining terms: #{remaining_terms} for iid: #{iid}" }
      #
      #     count_popped = (iid_terms.size - remaining_terms.size).to_u32
      #
      #     if count_popped > 0
      #       if remaining_terms.empty?
      #         Log.info "nuke whole bucket for pop executor" }
      #
      #         executor_ensure_op!(kv_action.batch_flush_bucket(iid, oid, iid_terms_hashed_vec))
      #       else
      #         Log.info "nuke only certain terms for pop executor" }
      #
      #         pop_terms.each do |pop_term, pop_term_hashed|
      #           if iid_terms.include?(pop_term_hashed)
      #             if let Ok(Some(mut pop_term_iids)) = kv_action.get_term_to_iids(pop_term_hashed)
      #               pop_term_iids.retain { |cur_iid| cur_iid != iid }
      #
      #               if pop_term_iids.empty?
      #                 executor_ensure_op!(kv_action.delete_term_to_iids(pop_term_hashed))
      #                 if fst_action.pop_word(pop_term)
      #                   Log.debug { "pop term hash nuked from graph: #{pop_term_hashed}" }
      #                 end
      #               else
      #                 executor_ensure_op!(kv_action.set_term_to_iids(pop_term_hashed, pop_term_iids))
      #               end
      #             else
      #               Log.error { "failed getting term-to-iids in pop executor" }
      #             end
      #           end
      #         end
      #
      #         remaining_terms_vec = remaining_terms.to_a
      #         executor_ensure_op!(kv_action.set_iid_to_terms(iid, remaining_terms_vec))
      #       end
      #     end
      #   else
      #     Log.error { "failed getting iid-to-terms in pop executor" }
      #   end
      #
      # end

      count_popped
    end
  end
end
