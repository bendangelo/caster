module Pipe

  enum MessageResult
    Close
    Continue
  end

  class Message
    COMMAND_ELAPSED_MILLIS_SLOW_WARN = 50_u128

    def self.handle_mode(mode : Mode, message : String)
      command, parts = extract message

      case command.byte_at?(0)
      when 'P'.ord # ping
        CommandResult.new ResponseType::Pong
      when 'E'.ord # exit
        CommandResult.new ResponseType::Ended, "exit"
      else
        case mode
        when Mode::Search
          search_mode command, parts
        when Mode::Ingest
          ingest_mode command, parts
        when Mode::Control
          control_mode command, parts
        else
          CommandResult.new ResponseType::Void, "unhandled command"
        end
      end

    end

    def self.search_mode(command, parts)
      case command.byte_at?(0)
      when 'Q'.ord # query
        SearchCommand.dispatch_query parts
      when 'S'.ord # suggest
        SearchCommand.dispatch_suggest parts
      when 'L'.ord # list
        return SearchCommand.dispatch_list parts
        # when "H" # help
        #   return SearchCommand.dispatch_help parts
      else
        CommandResult.new ResponseType::Void, "command not found"
      end
    end

    def self.ingest_mode(command, parts)
      case command
      when "PUSH" # upsert
        IngestCommand.dispatch_push parts
      when "POP"
        IngestCommand.dispatch_pop parts
      when "COUNT"
        IngestCommand.dispatch_count parts
      when "FLUSHC"
        IngestCommand.dispatch_flushc parts
      when "FLUSHB"
        IngestCommand.dispatch_flushb parts
      when "FLUSHO"
        IngestCommand.dispatch_flusho parts
        # when "HELP"
        #   return SearchCommand.dispatch_list parts
      else
        CommandResult.new ResponseType::Void, "command not found"
      end
    end

    def self.control_mode(command, parts)
      case command
        when "TRIGGER"
          ControlCommand.dispatch_trigger parts
        when "INFO"
          ControlCommand.dispatch_info parts
        when "COUNT"
          IngestCommand.dispatch_count parts
        when "FLUSHC"
          IngestCommand.dispatch_flushc parts
        when "FLUSHB"
          IngestCommand.dispatch_flushb parts
        when "FLUSHO"
          IngestCommand.dispatch_flusho parts
        # when "HELP"
        #   return SearchCommand.dispatch_list parts
      else
        CommandResult.new ResponseType::Void, "command not found"
      end
    end

    def self.on(mode, stream, message)
      command_start = Time.monotonic
      continue_pipe = MessageResult::Continue

      Log.debug { "got pipe message: (#{message})" }

      # TODO: handle shutting down
      # if !CHANNEL_AVAILABLE.read
      #   # Server going down, reject command
      #   response_args_groups = [CommandResponse::Err(CommandError::ShuttingDown).to_args]
      # else
      result = handle_mode mode, message
      # end

      # Serve response messages on socket
      if result.is_a? Tuple
        result.each do |args|
          puts_message stream, args.type, args.value

          continue_pipe = MessageResult::Close if args.type == ResponseType::Ended
        end
      else
        puts_message stream, result.type, result.value

        continue_pipe = MessageResult::Close if result.type == ResponseType::Ended
      end

      # Measure and log time it took to execute command
      # Notice: this is critical as to raise developer awareness on the performance bits when \
      #   altering commands-related code, or when making changes to underlying store executors.
      command_took = (Time.monotonic - command_start) * 1_000

      if command_took.to_i >= COMMAND_ELAPSED_MILLIS_SLOW_WARN
        Log.warn { "took a lot of time: #{command_took}ms to process pipe message" }
      else
        Log.info { "took #{command_took}ms/#{command_took * 1_000}us/#{command_took * 1_000_000}ns to process channel message" }
        end

      # Update command statistics
      # Notice: commands that take 0ms are not accounted for there (ie. those are usually \
      #   commands that do no work or I/O; they would make statistics less accurate)
      # Important: acquire write locks instead of read + write locks, as to prevent \
      #   deadlocks (explained here: https://github.com/valeriansaliou/sonic/pull/211)
      command_took_millis = command_took.to_i

      # COMMAND_LATENCY_WORST.write do |worst|
      #   *worst = command_took_millis if command_took_millis > *worst
      # end
      #
      # COMMAND_LATENCY_BEST.write do |best|
      #   *best = command_took_millis if command_took_millis > 0 && (*best == 0 || command_took_millis < *best)
      # end
      #
      # COMMANDS_TOTAL.write { |total| total + 1 }

      continue_pipe
    end

    def self.puts_message(stream, response_type, response_values)
      if response_values.blank?
        message = "#{response_type.to_s.upcase}#{Handle::LINE_FEED}"
      else
        message = "#{response_type.to_s.upcase} #{response_values}#{Handle::LINE_FEED}"
      end

      stream.puts message

      Log.debug { "wrote response with values: (#{message})" }
    end

    def self.extract(message : String) : {String, Array(String)}
      # Extract command name and arguments
      parts = message.split " "
      command = parts.shift

      Log.debug { "will dispatch search command: (#{command})" }

      {command, parts}
    end

  end

end
