module Pipe
  class IngestCommand

    def self.dispatch_push(parts) : CommandResult
      collection, bucket, object, text = parts.shift?, parts.shift?, parts.shift?, BaseCommand.parse_text_parts(parts)

      if collection && bucket && object && text
        Log.info { "dispatching ingest push in collection: #{collection}, bucket: #{bucket} and object: #{object} with text (#{text})" }

        # Define push parameters
        push_lang = nil

        # # Parse meta parts (meta comes after text; extract meta parts second)
        last_meta_err = nil

        # while (meta_result = BaseCommand.parse_next_meta_parts(parts))
        #   case handle_push_meta(meta_result)
        #   when Ok(Some(push_lang_parsed))
        #     push_lang = push_lang_parsed
        #   when Err(parse_err)
        #     last_meta_err = parse_err
        #   end
        # end

        if last_meta_err
          return CommandResult.error CommandError::InvalidFormat, last_meta_err
        else
          Log.info { "will push for text: #{text} with hinted locale: #{push_lang}" }

          # Commit 'push' query
            BaseCommand.commit_ok_operation Query::Builder.push(collection, bucket, object, text, push_lang)

        end
      else
        CommandResult.error CommandError::InvalidFormat, "PUSH <collection> <bucket> <object> \"<text>\" [LANG(<locale>)]?"
      end
    end

    def self.dispatch_pop(parts) : CommandResult
      collection, bucket, object, text, _ = parts.shift?, parts.shift?, parts.shift?, BaseCommand.parse_text_parts(parts), parts.shift?
      #
      # if collection && bucket && object && text && !_
      #   puts "dispatching ingest pop in collection: #{collection}, bucket: #{bucket} and object: #{object}"
      #   puts "ingest pop has text: #{text}"
      #
      #   # Make 'pop' query
      #   BaseCommand.commit_result_operation(
      #     QueryBuilder.pop(collection, bucket, object, text)
      #   )
      # else
      return CommandResult.error CommandError::InvalidFormat, "POP <collection> <bucket> <object> \"<text>\""
      # end
    end

    # def self.dispatch_count(parts : Slice(String)) : CommandResult
    #   collection, bucket_part, object_part, _ = parts.shift?, parts.shift?, parts.shift?, parts.shift?
    #
    #   if collection && !bucket_part && !object_part && !_
    #     puts "dispatching ingest count in collection: #{collection}"
    #
    #     # Make 'count' query
    #     BaseCommand.commit_result_operation(
    #       QueryBuilder.count(collection, bucket_part, object_part)
    #     )
    #   else
    #     return Err(PipeCommandError::InvalidFormat.new("COUNT <collection> [<bucket> [<object>]?]?"))
    #   end
    # end
    #
    # def self.dispatch_flushc(parts : Slice(String)) : CommandResult
    #   collection, _ = parts.shift?, parts.shift?
    #
    #   if collection && !_
    #     puts "dispatching ingest flush collection in collection: #{collection}"
    #
    #     # Make 'flushc' query
    #     BaseCommand.commit_result_operation(
    #       QueryBuilder.flushc(collection)
    #     )
    #   else
    #     return Err(PipeCommandError::InvalidFormat.new("FLUSHC <collection>"))
    #   end
    # end
    #
    # def self.dispatch_flushb(parts : Slice(String)) : CommandResult
    #   collection, bucket, _ = parts.shift?, parts.shift?, parts.shift?
    #
    #   if collection && bucket && !_
    #     puts "dispatching ingest flush bucket in collection: #{collection}, bucket: #{bucket}"
    #
    #     # Make 'flushb' query
    #     BaseCommand.commit_result_operation(
    #       QueryBuilder.flushb(collection, bucket)
    #     )
    #   else
    #     return Err(PipeCommandError::InvalidFormat.new("FLUSHB <collection> <bucket>"))
    #   end
    # end
    #
    # def self.dispatch_flusho(parts : Slice(String)) : CommandResult
    #   collection, bucket, object, _ = parts.shift?, parts.shift?, parts.shift?, parts.shift?
    #
    #   if collection && bucket && object && !_
    #     puts "dispatching ingest flush object in collection: #{collection}, bucket: #{bucket}, object: #{object}"
    #
    #     # Make 'flusho' query
    #     BaseCommand.commit_result_operation(
    #       QueryBuilder.flusho(collection, bucket, object)
    #     )
    #   else
    #     return Err(PipeCommandError::InvalidFormat.new("FLUSHO <collection> <bucket> <object>"))
    #   end
    # end
    #
    # def self.dispatch_help(parts : Slice(String)) : CommandResult
    #   BaseCommand.generic_dispatch_help(parts, &*MANUAL_MODE_INGEST)
    # end
    #
    # def self.handle_push_meta(meta_result : MetaPartsResult) : Result(Option(QueryGenericLang), PipeCommandError)
    #   case meta_result
    #   when Ok([meta_key, meta_value])
    #     puts "handle push meta: #{meta_key} = #{meta_value}"
    #
    #     case meta_key
    #     when "LANG"
    #       # 'LANG(<locale>)' where <locale> ∈ ISO 639-3
    #       query_lang_parsed = QueryGenericLang.from_value(meta_value)
    #
    #       if query_lang_parsed
    #         Ok(Some(query_lang_parsed))
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
  end
end
