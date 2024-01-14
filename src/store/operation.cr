module Store
  class Operation

    def self.dispatch(query)
      # Dispatch de-constructed query to its target executor
      if query.is_a? Query::Result
        case query.type
        when Query::Type::List
          Executer::List.execute(query.item, query.query_id, query.limit, query.offset)
            .join " "
        when Query::Type::Count
          Executer::Count.execute(query.item).to_s
        when Query::Type::FlushC
          Executer::FlushC.execute(query.item).to_s
        when Query::Type::FlushB
          Executer::FlushB.execute(query.item).to_s
        when Query::Type::FlushO
          Executer::FlushO.execute(query.item).to_s
        else
          Log.error { "Query type #{query.type} not found!" }
        end
      else
        case query.type
        when Query::Type::Search
          Executer::Search.execute(query.item, query.query_id, query.token, query.limit, query.offset)
            .join(" ")
        when Query::Type::Suggest
          Executer::Suggest.execute(query.item, query.query_id, query.token, query.limit)
            .join " "
        when Query::Type::Pop
          Executer::Pop.execute(query.item, query.token).to_s
        else
          Log.error { "Query type #{query.type} not found!" }
        end
      end
    end
  end
end
