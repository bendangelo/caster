module Pipe

  enum MessageResult
    Close
    Continue
  end

  class Message
    COMMAND_ELAPSED_MILLIS_SLOW_WARN = 50_u128

    def self.handle_mode(mode : Mode, message : String) : CommandResult
      command, parts = extract message

      case command
      when "PING"
        CommandResult.new ResponseType::Pong
      when "QUIT"
        CommandResult.new ResponseType::Ended, "quit"
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
      case command
      # when "QUERY"
      #   SearchCommand.dispatch_query parts
        # when "SUGGEST"
        #   return SearchCommand.dispatch_suggest parts
        # when "LIST"
        #   return SearchCommand.dispatch_list parts
        # when "HELP"
        #   return SearchCommand.dispatch_list parts
      else
        CommandResult.new ResponseType::Void, "command not found"
      end
    end

    def self.ingest_mode(command, parts)
      case command
      when "PUSH"
        IngestCommand.dispatch_push parts
      when "POP"
        IngestCommand.dispatch_pop parts
        # when "COUNT"
        #   IngestCommand.dispatch_count parts
        # when "FLUSHC"
        #   IngestCommand.dispatch_flushc parts
        # when "FLUSHB"
        #   IngestCommand.dispatch_flushb parts
        # when "FLUSHO"
        #   IngestCommand.dispatch_flusho parts
        # when "HELP"
        #   return SearchCommand.dispatch_list parts
      else
        CommandResult.new ResponseType::Void, "command not found"
      end
    end

    def self.control_mode(command, parts)
      case command
        # when "TRIGGER"
        #   ControlCommand.dispatch_trigger parts
        # when "INFO"
        #   ControlCommand.dispatch_info parts
        # when "COUNT"
        #   IngestCommand.dispatch_count parts
        # when "FLUSHC"
        #   IngestCommand.dispatch_flushc parts
        # when "FLUSHB"
        #   IngestCommand.dispatch_flushb parts
        # when "FLUSHO"
        #   IngestCommand.dispatch_flusho parts
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
      # response_args_groups.each do |response_args|
      puts_message stream, result.type, result.value

      continue_pipe = MessageResult::Close if result.type == ResponseType::Ended
      # end

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
      stream.puts "#{response_type.to_s.upcase} #{response_values}#{Handle::LINE_FEED}"

      Log.debug { "wrote response with values: #{response_type} (#{response_values})" }
    end

    def self.extract(message : String) : {String, Array(String)}
      # Extract command name and arguments
      parts = message.split " "
      command = parts.shift.upcase

      Log.debug { "will dispatch search command: (#{command})" }

      {command, parts}
    end

  end

end
