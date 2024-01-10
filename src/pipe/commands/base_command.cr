module Pipe

  enum CommandError
    None
    UnknownCommand
    NotFound
    QueryError
    InternalError
    ShuttingDown
    PolicyReject
    InvalidFormat
    InvalidMetaKey
    InvalidMetaValue
  end

  enum ResponseType
    Void
    Ok
    Pong
    Pending #(String)
    Result #(String)
    Event #(String, String, String)
    Ended #(String)
    Err #(CommandError)
  end

  struct CommandResult
    property type
    property value = nil
    property error = CommandError::None

    def initialize(@type : ResponseType)
    end

    def initialize(@type : ResponseType, @value : String)
    end

    def initialize(@type : ResponseType, @error : CommandError)
    end

    def initialize(@type : ResponseType, @value : String, @error : CommandError)
    end

    def self.ok : CommandResult
      CommandResult.new ResponseType::Ok
    end

    def self.error(error, value = "") : CommandResult
      CommandResult.new ResponseType::Err, value, error
    end

    def self.query_error : CommandResult
      CommandResult.new ResponseType::Err, CommandError::QueryError
    end

    def self.make_error_invalid_meta_key(meta_key : String, meta_value : String)
      CommandResult.new(ResponseType::Err, "#{meta_key} #{meta_value}", CommandError::InvalidMetaKey)
    end

    def self.make_error_invalid_meta_value(meta_key : String, meta_value : String)
      CommandResult.new(ResponseType::Err, "#{meta_key} #{meta_value}", CommandError::InvalidMetaValue)
    end

  end

  class BaseCommand
    EVENT_ID_SIZE = 8

    TEXT_PART_BOUNDARY = '"'
    TEXT_PART_ESCAPE = '\\'
    META_PART_GROUP_OPEN = '('
    META_PART_GROUP_CLOSE = ')'

    BACKUP_KV_PATH = "kv"
    BACKUP_FST_PATH = "fst"

    def self.parse_text_parts(parts : Array(String)) : String?
      text = String.new

      parts.each do |text_part|
        text += " " unless text.empty?

        text += text_part

        if text.size > 1 && text[-1] == TEXT_PART_BOUNDARY
          count_escapes = 0

          if text.size > 1
            (text.size - 2).downto(0) do |index|
              break if text[index] != TEXT_PART_ESCAPE

              count_escapes += 1
            end
          end

          if count_escapes == 0 || (count_escapes % 2 == 0)
            break
          end
        end
      end

      if text.empty? || text.size < 2 || text[0] != TEXT_PART_BOUNDARY ||
          text[-1] != TEXT_PART_BOUNDARY
        Log.error { "could not properly parse text parts: #{text}" }
        nil
      else
        Log.info { "parsed text parts (still needs post-processing): (#{text})" }

        text_inner = text[1..text.size - 2]

        text_inner_string = Utils.unescape(text_inner)

        Log.info { "parsed text parts (post-processed): (#{text_inner_string})" }

        text_inner_string.blank? ? nil : text_inner_string
      end
    end

    def self.parse_next_meta_parts(parts : Array(String)) : Tuple(ResponseType, String, String)
        part = parts.shift?

      if part
        if !part.empty?
          index_open = part.index(META_PART_GROUP_OPEN)

          if index_open
            key_bound_start = 0
            key_bound_end = index_open
            value_bound_start = index_open + 1
            value_bound_end = part.size - 1

            if part[value_bound_end].ord.to_char == META_PART_GROUP_CLOSE
              key = part[key_bound_start..key_bound_end]
              value = part[value_bound_start..value_bound_end]

              unless key.include?(META_PART_GROUP_OPEN) || key.include?(META_PART_GROUP_CLOSE) ||
                  value.include?(META_PART_GROUP_OPEN) || value.include?(META_PART_GROUP_CLOSE)
                Log.debug { "parsed meta part as: #{key} = #{value}" }
                return {ResponseType::Ok, key, value}
              else
                Log.debug { "parsed meta part, but it contains reserved characters: #{key} = #{value}" }
                return {ResponseType::Err, key, value}
              end
            end
          end
        end

        Log.error { "could not parse meta part: #{part}" }
        {ResponseType::Err, "?", part}
      else
        nil
      end
    end

    def self.commit_ok_operation(query : Query::Result) : CommandResult
      CommandResult.error CommandError::QueryError if query.nil?

      Store::Operation.dispatch query

      CommandResult.ok
    end
    #
    # def self.commit_result_operation(query_builder : Query::Result) : CommandResult
    #   query_builder.and_then { |dispatch| dispatch.dispatch }
    #     .or { CommandResult.query_error }
    #     .and_then do |result|
    #     if result
    #       CommandResult.new(Result::Ok([ChannelCommandResponse::Result(result)]))
    #     else
    #       Result::Err(PipeCommandError::InternalError)
    #     end
    #   end
    # end

    # def self.commit_pending_operation(query_type : String, query_id : String, query_builder : Query::Result) : CommandResult
    #   query_builder.and_then { |dispatch| dispatch.dispatch }
    #     .map do |results|
    #     [
    #       ChannelCommandResponse::Pending(query_id),
    #       ChannelCommandResponse::Event(query_type, query_id, results.unwrap_or_default)
    #     ]
    #   end
    #     .or { CommandResult.query_error }
    # end

    def self.generate_event_id : String
      Array.new(EVENT_ID_SIZE) { rand(('A'.ord..'Z'.ord).to_a + ('0'.ord..'9'.ord).to_a).to_char }.join
    end

    private def self.unescape(text : String) : String
      # Implement the unescape function based on your requirements
      # This is a placeholder and needs to be adapted according to your needs
      text
    end
  end
end
