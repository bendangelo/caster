module Executer
  class Search
    @@debug = [] of String
    def self.debug
      @@debug
    end

    def self.execute(store : Store::Item, event_id : String, token : Lexer::Token, limit : Int32, offset : Int32)
      @@debug.clear

      # general_kv_access_lock_read!
      # general_fst_access_lock_read!
      bucket = store.bucket

      result_oids = Array(String).new limit

      if bucket.nil?
        Log.error { "bucket is nil" }
        return result_oids
      end

      kv_store = Store::KVPool.acquire(Store::KVAcquireMode::OpenOnly, store.collection)
      # StoreFSTPool.acquire(collection, bucket)
      # executor_kv_lock_read!(kv_store)

      kv_action = Store::KVAction.new(bucket: bucket, store: kv_store)
      # fst_action = StoreFSTActionBuilder.access(fst_store)

      found_iids = Set(UInt32).new
      positions = Hash(UInt32, Array(Int32)).new

      token.parse_text do |term, term_hashed, index|
        kv_action.iterate_term_to_iids(term_hashed, index, token.index_limit) do |iids, term_index|

          Log.debug { "got search executor iids: #{iids} for term: #{term}" }

          iids.each do |iid|
            positions[iid] ||= [] of Int32
            positions[iid] << token.index_limit - term_index - index
          end

          if found_iids.empty?
            found_iids = iids
          else
            found_iids = found_iids + iids
          end
        end

        # next if iids.nil?
        # higher_limit = APP_CONF.store.kv.retain_word_objects
        # alternates_try = APP_CONF.channel.search.query_alternates_try
        #
        # if iids.size < higher_limit && alternates_try > 0
        #   Log.debug { "not enough iids were found (#{iids.size}/#{higher_limit}), completing for term: #{term}" }
        #
        #   if suggested_words = fst_action.suggest_words(term, alternates_try + 1, 1)
        #     iids_new_len = iids.size
        #
        #     suggested_words.each do |suggested_word|
        #       next if suggested_word == term
        #
        #       Log.debug { "got completed word: #{suggested_word} for term: #{term}" }
        #
        #       if let Some(suggested_iids) = kv_action.get_term_to_iids(StoreTermHash.new(suggested_word)).unwrap_or(nil)
        #         suggested_iids.each do |suggested_iid|
        #           unless iids.include?(suggested_iid)
        #             iids << suggested_iid
        #             iids_new_len += 1
        #
        #             if iids_new_len >= higher_limit
        #               Log.debug { "got enough completed results for term: #{term}" }
        #               break
        #             end
        #           end
        #         end
        #       end
        #     end
        #
        #     Log.debug { "done completing results for term: #{term}, now #{iids_new_len} results" }
        #   else
        #     Log.debug { "did not get any completed word for term: #{term}" }
        #     end
        # end

        # Log.debug { "got search executor iids: #{iids} for term: #{term}" }
        #
        # if found_iids.empty?
        #   found_iids = iids
        # else
        #   found_iids = found_iids | iids
        # end

        Log.debug { "got search executor iid intersection: #{found_iids} for term: #{term}" }

        # if found_iids.size > limit
        #   break
        # end
      end

      found_iids = found_iids.to_a.sort_by do |iid|
        -positions[iid].sum
      end

      # TODO: add offset
      found_iids.each_with_index do |found_iid, index|
        break if index >= limit

        if oid = kv_action.get_iid_to_oid(found_iid)
          result_oids << oid
          @@debug << "#{oid} #{-positions[found_iid].sum} #{positions[found_iid].size}"
        else
          Log.error { "failed getting search executor iid-to-oid" }
        end
      end

      Log.info { "got search executor final oids: #{result_oids}" }

      result_oids
    end
  end

end
