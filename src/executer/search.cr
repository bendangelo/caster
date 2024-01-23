module Executer
  class Search
    @@debug = [] of String
    def self.debug
      @@debug
    end

    def self.execute(store : Store::Item, token : Lexer::Token, limit : Int32, offset : Int32, filters : Array(Pipe::FilterParams)? = nil, dir = 0, order = 0)

      # general_kv_access_lock_read!
      # general_fst_access_lock_read!
      bucket = store.bucket
      if dir <= 0
        dir = -1 # DESC
      else
        dir = 1 # ASC
      end

      order = 0 if order < 0

      if bucket.nil?
        Log.error { "bucket is nil" }
        return [] of String
      end

      result_oids = Array(String).new limit

      kv_store = Store::KVPool.acquire(Store::KVAcquireMode::OpenOnly, store.collection)
      # StoreFSTPool.acquire(collection, bucket)
      # executor_kv_lock_read!(kv_store)

      kv_action = Store::KVAction.new(bucket: bucket, store: kv_store)
      # fst_action = StoreFSTActionBuilder.access(fst_store)

      found_iids = Hash(UInt32, Int64).new

      token.parse_text do |term, term_hashed, index|

        Log.debug { "searching for term: #{term}" }

        kv_action.iterate_term_to_iids(term_hashed, 0, token.index_limit) do |iids, term_index|

          iids.each do |iid|

            if order == 0
              if found_iids.has_key? iid
                found_iids[iid] += token.index_limit.to_i64 - term_index - index
              else
                found_iids[iid] = token.index_limit.to_i64 - term_index - index
              end
              # use attr for ordering
            elsif (attrs = kv_action.get_iid_to_attrs(iid)) && (attr_value = attrs[order - 1]?)
              found_iids[iid] = attr_value.to_i64
            else
              # no value, use default
              found_iids[iid] = 0
            end
          end

          # TODO: suggest_words

        end

      end

      # filter iids
      found_iids.each_key do |iid|

        attrs = kv_action.get_iid_to_attrs(iid)

        if attrs.nil?
          next
        end

        if filters
          filter_out = filters.any? do |i|
            attr_value = attrs[i.attr]?
            if attr_value.nil?
              true # not matched the filter, so discard it
            else
              !Executer::Filter.execute(i.method, attr_value, i.value_first, i.value_second)
            end
          end

          if filter_out
            found_iids.delete(iid)
            next
          end
        end

        if attr_value = attrs[order]?
          if order == Caster.settings.search.popularity_index
            found_iids[iid] = (found_iids[iid] * attr_value.to_i64 * Caster.settings.search.popularity_weight + found_iids[iid] * (1 - Caster.settings.search.popularity_weight)).to_i64
          else
            found_iids[iid] = attr_value.to_i64
          end
        end
      end

      sorted_iids = found_iids.to_a.unstable_sort_by do |k, v|
        v * dir # in reverse
      end

      sorted_iids.each_with_index do |(iid, value), index|
        next if index < offset
        break if index >= limit + offset

        if oid = kv_action.get_iid_to_oid(iid)
          result_oids << oid
          # @@debug << "#{oid} #{-positions[iid].sum} #{positions[iid].size}"
        else
          Log.error { "failed getting search executor iid-to-oid" }
        end
      end

      # Log.info { "got search executor final oids: #{result_oids}" }

      result_oids
    end
  end

  def self.suggest_words
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

  end

end
