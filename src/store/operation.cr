module Store
  class Operation
    def self.dispatch(query : Query::Result)
      # Dispatch de-constructed query to its target executor
      case query.type
        # when Query::Type::Search
        #   Executer::Search.execute(query.store, query.query_id, query.lexer, query.limit, query.offset)
        #     .map do |results|
        #     results.map { |result| result.join(" ") }
        #   end
        # when Query::Type::Suggest
        #   Executer::Suggest.execute(query.store, query.query_id, query.lexer, query.limit)
        #     .map do |results|
        #     results.map { |result| result.join(" ") }
        #   end
        # when Query::Type::List
        #   Executer::List.execute(query.store, query.query_id, query.limit, query.offset)
        #     .map { |results| results.join(" ") }
        #     .map { |results| Some(results) }
      when Query::Type::Push
        Executer::Push.execute(query.store, query.text)
        # when Query::Type::Pop
        #   Executer::Pop.execute(query.store, query.lexer).map { |count| Some(count.to_s) }
        # when Query::Type::Count
        #   Executer::Count.execute(query.store).map { |count| Some(count.to_s) }
        # when Query::Type::FlushC
        #   Executer::FlushC.execute(query.store).map { |count| Some(count.to_s) }
        # when Query::Type::FlushB
        #   Executer::FlushB.execute(query.store).map { |count| Some(count.to_s) }
        # when Query::Type::FlushO
        #   Executer::FlushO.execute(query.store).map { |count| Some(count.to_s) }
      else
        Log.error { "Query type #{query.type} not found!" }
      end
    end
  end
end
