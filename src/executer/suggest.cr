module Executer
  class Suggest
    def self.execute(store : Store::Item, event_id : String, token : Lexer::Token, limit : Int32)
      # if let Store::Item(collection, Some(bucket), Nil) = store
      #   general_fst_access_lock_read!
      #
      #   if let Ok(fst_store) = StoreFSTPool.acquire(collection, bucket)
      #     fst_action = StoreFSTActionBuilder.access(fst_store)
      #
      #     if let Some((word, Nil)) = lexer.next, lexer.next
      #       debug "running suggest on word: #{word}"
      #
      #       return Ok(fst_action.suggest_words(word, limit.to_i, nil))
      #     end
      #   end
      # end

      [] of String
    end
  end
end
