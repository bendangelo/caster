module Pipe
  class SearchCommand
    def self.dispatch_query(parts)
      collection, bucket, text = parts.shift?, parts.shift?, BaseCommand.parse_text_parts(parts)

      if collection && bucket && text
        # Generate command identifier
        event_id = BaseCommand.generate_event_id

        Log.info { "dispatching search query ##{event_id} on collection: #{collection} and bucket: #{bucket}" }

        # Define query parameters
        query_limit = Caster.settings.search.query_limit_default
        query_offset = 0
        query_lang = nil

        # Parse meta parts (meta comes after text; extract meta parts second)
        last_meta_err = nil

        # while (meta_result = BaseCommand.parse_next_meta_parts(parts))
        #   case handle_query_meta(meta_result)
        #   when Ok([Some(query_limit_parsed), Nil, Nil])
        #     query_limit = query_limit_parsed
        #   when Ok([Nil, Some(query_offset_parsed), Nil])
        #     query_offset = query_offset_parsed
        #   when Ok([Nil, Nil, Some(query_lang_parsed)])
        #     query_lang = query_lang_parsed
        #   when Err(parse_err)
        #     last_meta_err = parse_err
        #   end
        # end

        if last_meta_err
          return CommandResult.error CommandError::InvalidMetaKey, last_meta_err
        elsif query_limit < 1 || query_limit > Caster.settings.search.query_limit_maximum
          return CommandResult.error CommandError::PolicyReject, "LIMIT out of minimum/maximum bounds"
        else
          Log.info { "will search for ##{event_id} with text: #{text}, limit: #{query_limit}, offset: #{query_offset}, locale: <#{query_lang}>" }

          # Commit 'search' query
          BaseCommand.commit_pending_operation(
            "QUERY", event_id, Query::Builder.search(
              event_id, collection, bucket, text, query_limit, query_offset, query_lang
            )
          )
        end
      else
        return CommandResult.error CommandError::InvalidFormat, "QUERY <collection> <bucket> \"<terms>\" [LIMIT(<count>)]? [OFFSET(<count>)]? [LANG(<locale>)]?"
      end
    end

    def self.dispatch_suggest(parts)
      collection, bucket, text = parts.shift?, parts.shift?, BaseCommand.parse_text_parts(parts)

      if collection && bucket && text
        # Generate command identifier
        event_id = BaseCommand.generate_event_id

        puts "dispatching search suggest ##{event_id} on collection: #{collection} and bucket: #{bucket}"

        # Define suggest parameters
        suggest_limit = Caster.settings.search.suggest_limit_default

        # Parse meta parts (meta comes after text; extract meta parts second)
        last_meta_err = nil

        # while (meta_result = BaseCommand.parse_next_meta_parts(parts))
        #   case handle_suggest_meta(meta_result)
        #   when Ok(Some(suggest_limit_parsed))
        #     suggest_limit = suggest_limit_parsed
        #   when Err(parse_err)
        #     last_meta_err = parse_err
        #   end
        # end

        if last_meta_err
          return CommandResult.error CommandError::InvalidMetaKey, last_meta_err
        elsif suggest_limit < 1 || suggest_limit > Caster.settings.search.suggest_limit_maximum
          return CommandResult.error CommandError::PolicyReject, "LIMIT out of minimum/maximum bounds"
        else
          Log.info { "will suggest for ##{event_id} with text: #{text}, limit: #{suggest_limit}" }

          # Commit 'suggest' query
          BaseCommand.commit_pending_operation(
            "SUGGEST", event_id, Query::Builder.suggest(event_id, collection, bucket, text, suggest_limit)
          )
        end
      else
        return CommandResult.error CommandError::InvalidFormat, "SUGGEST <collection> <bucket> \"<word>\" [LIMIT(<count>)]?"
      end
    end

    def self.dispatch_list(parts)
      collection, bucket = parts.shift?, parts.shift?

      if collection && bucket
        # Generate command identifier
        event_id = BaseCommand.generate_event_id

        puts "dispatching search list ##{event_id} on collection: #{collection} and bucket: #{bucket}"

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
        return CommandResult.error CommandError::InvalidFormat, "LIST <collection> <bucket> [LIMIT(<count>)]? [OFFSET(<count>)]?"
      end
    end

    # def self.dispatch_help(parts : Slice(String)) : CommandResult
    #   BaseCommand.generic_dispatch_help(parts, &*MANUAL_MODE_SEARCH)
    # end
    #
    # def self.handle_query_meta(meta_result : MetaPartsResult) : Result(QueryMetaData, PipeCommandError)
    #   case meta_result
    #   when Ok([meta_key, meta_value])
    #     puts "handle query meta: #{meta_key} = #{meta_value}"
    #
    #     case meta_key
    #     when "LIMIT"
    #       # 'LIMIT(<count>)' where 0 <= <count> < 2^16
    #       query_limit_parsed = meta_value.to_i64
    #
    #       if query_limit_parsed >= 0 && query_limit_parsed < 2^16
    #         Ok([Some(query_limit_parsed), Nil, Nil])
    #       else
    #         Err(BaseCommand.make_error_invalid_meta_value(meta_key, meta_value))
    #       end
    #     when "OFFSET"
    #       # 'OFFSET(<count>)' where 0 <= <count> < 2^32
    #       query_offset_parsed = meta_value.to_i64
    #
    #       if query_offset_parsed >= 0 && query_offset_parsed < 2^32
    #         Ok([Nil, Some(query_offset_parsed), Nil])
    #       else
    #         Err(BaseCommand.make_error_invalid_meta_value(meta_key, meta_value))
    #       end
    #     when "LANG"
    #       # 'LANG(<locale>)' where <locale> ∈ ISO 639-3
    #       query_lang_parsed = QueryGenericLang.from_value(meta_value)
    #
    #       if query_lang_parsed
    #         Ok([Nil, Nil, Some(query_lang_parsed)])
    #       else
    #         Err(BaseCommand.make_error_invalid_meta_value(meta_key, meta_value))
    #       end
    #     else
    #       Err(BaseCommand.make_error_invalid_meta_key(meta_key, meta_value))
    #     end
    #   when Err(err)
    #     Err(BaseCommand.make_error_invalid_meta_key(err[0], err[1]))
    #   end
    # end

    # def self.handle_suggest_meta(meta_result : MetaPartsResult) : Result(Option(QuerySearchLimit), PipeCommandError)
    #   case meta_result
    #   when Ok([meta_key, meta_value])
    #     puts "handle suggest meta: #{meta_key} = #{meta_value}"
    #
    #     case meta_key
    #     when "LIMIT"
    #       # 'LIMIT(<count>)' where 0 <= <count> < 2^16
    #       suggest_limit_parsed = meta_value.to_i64
    #
    #       if suggest_limit_parsed >= 0 && suggest_limit_parsed < 2^16
    #         Ok(Some(suggest_limit_parsed))
    #       else
    #         Err(BaseCommand.make_error_invalid_meta_value(meta_key, meta_value))
    #       end
    #     else
    #       Err(BaseCommand.make_error_invalid_meta_key(meta_key, meta_value))
    #     end
    #   when Err(err)
    #     Err(BaseCommand.make_error_invalid_meta_key(err[0], err[1]))
    #   end
    # end
    #
    # def self.handle_list_meta(meta_result : MetaPartsResult) : Result(ListMetaData, PipeCommandError)
    #   case meta_result
    #   when Ok([meta_key, meta_value])
    #     puts "handle list meta: #{meta_key} = #{meta_value}"
    #
    #     case meta_key
    #     when "LIMIT"
    #       # 'LIMIT(<count>)' where 0 <= <count> < 2^16
    #       list_limit_parsed = meta_value.to_i64
    #
    #       if list_limit_parsed >= 0 && list_limit_parsed < 2^16
    #         Ok([Some(list_limit_parsed), Nil])
    #       else
    #         Err(BaseCommand.make_error_invalid_meta_value(meta_key, meta_value))
    #       end
    #     when "OFFSET"
    #       # 'OFFSET(<count>)' where 0 <= <count> < 2^32
    #       list_offset_parsed = meta_value.to_i64
    #
    #       if list_offset_parsed >= 0 && list_offset_parsed < 2^32
    #         Ok([Nil, Some(list_offset_parsed)])
    #       else
    #         Err(BaseCommand.make_error_invalid_meta_value(meta_key, meta_value))
    #       end
    #     else
    #       Err(BaseCommand.make_error_invalid_meta_key(meta_key, meta_value))
    #     end
    #   when Err(err)
    #     Err(BaseCommand.make_error_invalid_meta_key(err[0], err[1]))
    #   end
    end
  end
