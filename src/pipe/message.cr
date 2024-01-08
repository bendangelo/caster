module Pipe

  enum MessageResult
    Close
    Continue
  end

  module MessageMode
    def self.handle(message : String) : Tuple(ResponseType, String)
      command, parts = extract message

      type, msg = handle_mode message

      if type != ResponseType.None
        return {type, msg}
      end

      case command
      when "PING"
        {ResponseType.Pong, ""}
      when "QUIT"
        {ResponseType.Ended, "quit"}
      else
        {ResponseType.None, ""}
      end
    end

    def self.handle_mode(message)
      {ResponseType.None, ""}
    end

    def self.extract(message : String) : {String, Array(String)}
      # Extract command name and arguments
      parts = message.split " "
      command = parts.first.to_s.upcase

      debug "will dispatch search command: #{command}"

      parts.shift

      {command, parts}
    end
  end

  class Message
    COMMAND_ELAPSED_MILLIS_SLOW_WARN = 50_u128

    def self.on(mode : MessageMode, stream : TCPSocket, message_slice : Slice(UInt8))
      message = String.new(message_slice)
      command_start = Time.monotonic
      result = MessageResult::Continue

      Log.debug { "got pipe message: #{message}" }

      # TODO: handle shutting down
      # if !CHANNEL_AVAILABLE.read
      #   # Server going down, reject command
      #   response_args_groups = [CommandResponse::Err(CommandError::ShuttingDown).to_args]
      # else
      response_type, response_values = mode.handle message
      # end

      # Serve response messages on socket
      # response_args_groups.each do |response_args|
      if response_type != ResponseType::None
        # values_string = response_args[1].map(&.to_s).join(" ") if response_args[1]

        stream.puts "#{response_type} #{response_values}#{LINE_FEED}"

        Log.debug { "wrote response with values: #{response_type} (#{response_values})" }
      end
      # end

      # Measure and log time it took to execute command
      # Notice: this is critical as to raise developer awareness on the performance bits when \
      #   altering commands-related code, or when making changes to underlying store executors.
      command_took = (Time.monotonic - command_start) * 1_000

      if command_took >= COMMAND_ELAPSED_MILLIS_SLOW_WARN
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

      result
    end
  end

  class MessageModeSearch
    extend MessageMode

    def self.handle_mode(message : String)
      {ResponseType.None, ""}
    end
  end

  class MessageModeIngest
    extend MessageMode

    def self.handle_mode(message : String)
      {ResponseType.None, ""}
    end
  end

  class MessageModeControl
    extend MessageMode

    def self.handle_mode(message : String)
      {ResponseType.None, ""}
    end
  end

end
