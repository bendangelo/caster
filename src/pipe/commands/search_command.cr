module Pipe
  class SearchCommand
    def self.dispatch_query(input)
      parts, text = BaseCommand.parse_args_with_text(input)
      collection, bucket = parts.shift?, parts.shift?

      if collection && bucket && text
        # Generate command identifier
        event_id = BaseCommand.generate_event_id

        Log.info { "dispatching search query ##{event_id} on collection: #{collection} and bucket: #{bucket}" }

        # Define query parameters

        query_limit = BaseCommand.parse_meta(parts, "LIMIT", Caster.settings.search.query_limit_default).to_i
        query_offset = BaseCommand.parse_meta(parts, "OFFSET", 0).to_i
        query_lang = BaseCommand.parse_meta parts, "LANG"

        if query_limit < 1 || query_limit > Caster.settings.search.query_limit_maximum
          return CommandResult.error CommandError::PolicyReject, "LIMIT out of minimum/maximum bounds"
        else
          Log.info { "will search for ##{event_id} with text: #{text}, limit: #{query_limit}, offset: #{query_offset}, locale: <#{query_lang}>" }

          # results = Executer::Search.execute(query.item, query.query_id, query.token, query.limit, query.offset)
          #   .join(" ")

          # Commit 'search' query
          BaseCommand.commit_pending_operation(
            "QUERY", event_id, Query::Builder.search(
              event_id, collection, bucket, text, query_limit, query_offset, query_lang
            )
          )
        end
      else
        return CommandResult.error CommandError::InvalidFormat, "QUERY <collection> <bucket> [LIMIT <count>]? [OFFSET <count>]? [LANG <locale>]? -- <terms>"
      end
    end

    def self.dispatch_suggest(input)
      parts, text = BaseCommand.parse_args_with_text(input)
      collection, bucket = parts.shift?, parts.shift?

      if collection && bucket && text
        # Generate command identifier
        event_id = BaseCommand.generate_event_id

        Log.info { "dispatching search suggest ##{event_id} on collection: #{collection} and bucket: #{bucket}" }

        # Define suggest parameters
        suggest_limit = BaseCommand.parse_meta(parts, "LIMIT", Caster.settings.search.suggest_limit_default).to_i

        if suggest_limit < 1 || suggest_limit > Caster.settings.search.suggest_limit_maximum
          return CommandResult.error CommandError::PolicyReject, "LIMIT out of minimum/maximum bounds"
        else
          Log.info { "will suggest for ##{event_id} with text: #{text}, limit: #{suggest_limit}" }

          # Commit 'suggest' query
          BaseCommand.commit_pending_operation(
            "SUGGEST", event_id, Query::Builder.suggest(event_id, collection, bucket, text, suggest_limit)
          )
        end
      else
        return CommandResult.error CommandError::InvalidFormat, "SUGGEST <collection> <bucket> [LIMIT <count>]? -- <word>"
      end
    end

    def self.dispatch_list(input)
      parts = BaseCommand.parse_args(input)
      collection, bucket = parts.shift?, parts.shift?

      if collection && bucket
        # Generate command identifier
        event_id = BaseCommand.generate_event_id

        Log.info { "dispatching search list ##{event_id} on collection: #{collection} and bucket: #{bucket}" }

        # Define list parameters
        list_limit = 10#APP_CONF.channel.search.list_limit_default
        list_offset = 0

        # Parse meta parts (meta comes last; extract meta parts second)
        last_meta_err = nil

        # while (meta_result = BaseCommand.parse_next_meta_parts(parts))
        #   case handle_list_meta(meta_result)
        #   when Ok([Some(list_limit_parsed), Nil])
        #     list_limit = list_limit_parsed
        #   when Ok([Nil, Some(list_offset_parsed)])
        #     list_offset = list_offset_parsed
        #   when Err(parse_err)
        #     last_meta_err = parse_err
        #   end
        # end
        #
        if last_meta_err
          return CommandResult.error CommandError::InvalidMetaKey, last_meta_err
        elsif list_limit < 1 || list_limit > Caster.settings.search.list_limit_maximum
          return CommandResult.error CommandError::PolicyReject, "LIMIT out of minimum/maximum bounds"
        else
          # Commit 'list' query
          BaseCommand.commit_pending_operation(
            "LIST", event_id, Query::Builder.list(event_id, collection, bucket, list_limit, list_offset)
          )
        end
      else
        return CommandResult.error CommandError::InvalidFormat, "LIST <collection> <bucket> [LIMIT <count>]? [OFFSET <count>]?"
      end
    end

    # def self.dispatch_help(parts : Slice(String)) : CommandResult
    #   BaseCommand.generic_dispatch_help(parts, &*MANUAL_MODE_SEARCH)
    # end
    end
  end
