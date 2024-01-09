module Executer
  class Pop
    # def self.execute(store : StoreItem, lexer : TokenLexer) : Result(UInt32, Nil)
    #   if let StoreItem(collection, Some(bucket), Some(object)) = store
    #     general_kv_access_lock_read!
    #     general_fst_access_lock_read!
    #
    #     if let (Ok(kv_store), Ok(fst_store)) = (
    #       StoreKVPool.acquire(StoreKVAcquireMode::OpenOnly, collection),
    #       StoreFSTPool.acquire(collection, bucket)
    #     )
    #       executor_kv_lock_write!(kv_store)
    #
    #       kv_action = StoreKVActionBuilder.access(bucket, kv_store)
    #       fst_action = StoreFSTActionBuilder.access(fst_store)
    #
    #       oid = object.as_str
    #
    #       if let Ok(iid_value) = kv_action.get_oid_to_iid(oid)
    #         count_popped = 0
    #
    #         if let Some(iid) = iid_value
    #           if let Ok(Some(iid_terms_hashed_vec)) = kv_action.get_iid_to_terms(iid)
    #             info "got pop executor stored iid-to-terms: #{iid_terms_hashed_vec}"
    #
    #             pop_terms = lexer.collect
    #
    #             iid_terms_hashed = LinkedHashSet.new(iid_terms_hashed_vec.to_a)
    #
    #             remaining_terms = iid_terms_hashed.difference(
    #               LinkedHashSet.new(pop_terms.map { |item| item[1] })
    #             ).to_a.to_set
    #
    #             debug "got pop executor terms remaining terms: #{remaining_terms} for iid: #{iid}"
    #
    #             count_popped = (iid_terms_hashed.size - remaining_terms.size).to_u32
    #
    #             if count_popped > 0
    #               if remaining_terms.empty?
    #                 info "nuke whole bucket for pop executor"
    #
    #                 executor_ensure_op!(kv_action.batch_flush_bucket(iid, oid, iid_terms_hashed_vec))
    #               else
    #                 info "nuke only certain terms for pop executor"
    #
    #                 pop_terms.each do |pop_term, pop_term_hashed|
    #                   if iid_terms_hashed.include?(pop_term_hashed)
    #                     if let Ok(Some(mut pop_term_iids)) = kv_action.get_term_to_iids(pop_term_hashed)
    #                       pop_term_iids.retain { |cur_iid| cur_iid != iid }
    #
    #                       if pop_term_iids.empty?
    #                         executor_ensure_op!(kv_action.delete_term_to_iids(pop_term_hashed))
    #                         if fst_action.pop_word(pop_term)
    #                           debug "pop term hash nuked from graph: #{pop_term_hashed}"
    #                         end
    #                       else
    #                         executor_ensure_op!(kv_action.set_term_to_iids(pop_term_hashed, pop_term_iids))
    #                       end
    #                     else
    #                       error "failed getting term-to-iids in pop executor"
    #                     end
    #                   end
    #                 end
    #
    #                 remaining_terms_vec = remaining_terms.to_a
    #                 executor_ensure_op!(kv_action.set_iid_to_terms(iid, remaining_terms_vec))
    #               end
    #             end
    #           else
    #             error "failed getting iid-to-terms in pop executor"
    #           end
    #         end
    #
    #         return Ok(count_popped)
    #       end
    #     end
    #   end
    #
    #   Err(Nil)
    # end
  end
end
