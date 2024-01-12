module Pipe

  enum MessageResult
    Close
    Continue
  end

  class Message
    COMMAND_ELAPSED_MILLIS_SLOW_WARN = 50_u128

    def self.handle_mode(mode : Mode, message : String)
      command, args = extract message

      case command
      when "PING"
        CommandResult.new ResponseType::Pong
      when "QUIT"
        CommandResult.new ResponseType::Ended, "quit"
      else
        case mode
        when Mode::Search
          search_mode command, args
        when Mode::Ingest
          ingest_mode command, args
        when Mode::Control
          control_mode command, args
        else
          CommandResult.new ResponseType::Err, value: "unhandled command (#{command})", error: CommandError::NotFound
        end
      end

    end

    def self.search_mode(command, args)
      case command.byte_at?(0)
      when 'Q'.ord # query
        SearchCommand.dispatch_query args
      when 'S'.ord # suggest
        SearchCommand.dispatch_suggest args
      when 'L'.ord # list
        return SearchCommand.dispatch_list args
        # when "H" # help
        #   return SearchCommand.dispatch_help args
      else
        CommandResult.new ResponseType::Err, "command not found (#{command})", error: CommandError::NotFound
      end
    end

    def self.ingest_mode(command, args)
      case command
      when "PUSH" # upsert
        IngestCommand.dispatch_push args
      when "POP"
        IngestCommand.dispatch_pop args
      when "COUNT"
        IngestCommand.dispatch_count args
      when "FLUSHC"
        IngestCommand.dispatch_flushc args
      when "FLUSHB"
        IngestCommand.dispatch_flushb args
      when "FLUSHO"
        IngestCommand.dispatch_flusho args
        # when "HELP"
        #   return SearchCommand.dispatch_list args
      else
        CommandResult.new ResponseType::Err, "command not found (#{command})", error: CommandError::NotFound
      end
    end

    def self.control_mode(command, args)
      case command
        when "TRIGGER"
          ControlCommand.dispatch_trigger args
        when "INFO"
          ControlCommand.dispatch_info args
        when "COUNT"
          IngestCommand.dispatch_count args
        when "FLUSHC"
          IngestCommand.dispatch_flushc args
        when "FLUSHB"
          IngestCommand.dispatch_flushb args
        when "FLUSHO"
          IngestCommand.dispatch_flusho args
        # when "HELP"
        #   return SearchCommand.dispatch_list args
      else
        CommandResult.new ResponseType::Void, "command not found"
      end
    end

    def self.on(mode, stream, message)
      command_start = Time.monotonic
      continue_pipe = MessageResult::Continue

      Log.debug { "got pipe message: (#{message})" }

      if Listen.available?
        result = handle_mode mode, message
      else
        # Server going down, reject command
        result = CommandResult.new ResponseType::Ended, value: "shutting down"
      end

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

      Log.debug { "wrote response with values: (#{message.chomp})" }
    end

    def self.extract(message : String) : {String, String}
      # Extract command name and arguments
      parts = message.partition " "
      args = parts[2]?

      if args.nil? || args.blank?
        args = ""
      end

      Log.debug { "will dispatch command: (#{parts[0]}) args: (#{args})" }

      return parts[0], args
    end

  end

end
