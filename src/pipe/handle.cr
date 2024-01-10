module Pipe

  enum Mode
    Search
    Ingest
    Control
  end

  enum ResultError
    Closed
    InvalidMode
    AuthenticationRequired
    AuthenticationFailed
    NotRecognized
    Timeout
    ConnectionAborted
    Interrupted
    Unknown
  end

  class Handle
    CONNECTED_BANNER = "CONNECTED <Caster v1.0.0>"

    LINE_END_GAP = 1
    BUFFER_SIZE = 20_000
    MAX_LINE_SIZE = BUFFER_SIZE + LINE_END_GAP + 1
    TCP_TIMEOUT_NON_ESTABLISHED = 10
    PROTOCOL_REVISION = 1
    BUFFER_LINE_SEPARATOR = '\n'.ord
    LINE_FEED = "\r\n"

    class ChannelHandleError < Exception
    end

    def self.client(stream : TCPSocket)
      # Configure stream (non-established)
      configure_stream(stream, false)

      # Send connected banner
      stream.puts("#{CONNECTED_BANNER}#{LINE_FEED}")

      # Increment connected clients count
      # CLIENTS_CONNECTED.write { |count| count += 1 }

      # Ensure pipe mode is set
      result = ensure_start(stream)

      if result.is_a?(Mode) && Mode.valid?(result)
        # Configure stream (established)
        configure_stream(stream, true)

        # Send started acknowledgment (with environment variables)
        stream.puts("STARTED #{result.to_s} protocol(#{PROTOCOL_REVISION}) buffer(#{BUFFER_SIZE})#{LINE_FEED}")

        handle_stream(result, stream)
      else
        stream.puts("ENDED #{result}#{LINE_FEED}")
      end

      # Decrement connected clients count
      # CLIENTS_CONNECTED.write { |count| count -= 1 }
    rescue IO::TimeoutError
      Log.info { "Timeout client" }
      stream.puts("ENDED Timeout#{LINE_FEED}")
    end

    def self.configure_stream(stream : TCPSocket, is_established : Bool)
      tcp_timeout = is_established ? Caster.settings.tcp_timeout : TCP_TIMEOUT_NON_ESTABLISHED

      stream.tcp_nodelay = true
      stream.read_timeout = tcp_timeout * 60 # to minutes
      stream.write_timeout = tcp_timeout * 60
    end

    def self.handle_stream(mode, stream, max_line_size = MAX_LINE_SIZE, run_loop = true)
      # Initialize packet buffer
      buffer = Slice(UInt8).new(max_line_size)

      # Wait for incoming messages
      loop do
        read_length = stream.read(buffer)

        break if read_length == 0

        # Buffer overflow?
        buffer_len = read_length
        if buffer_len > max_line_size
          # Do not continue, as there is too much pending data in the buffer.
          # Most likely the client does not implement a proper back-pressure
          # management system, thus we terminate it.
          stream.puts("ENDED BufferOverflow#{LINE_FEED}")

          Log.error { "closing pipe thread because of buffer overflow" }
          raise "buffer overflow (#{buffer_len}/#{max_line_size} bytes)"
        end

        # Add chunk to buffer
        # buffer.join(buffer[0, read])

        # Handle full lines from buffer (keep the last incomplete line in buffer)
        processed_line = Slice(UInt8).new(max_line_size)
        index = 0
        processed_index = 0
        until index == read_length
          byte = buffer[index]

          # Commit line and start a new one?
          if byte == BUFFER_LINE_SEPARATOR

            # create line for message
            message = String.new(processed_line[0, processed_index])

            if Message.on(mode, stream, message) == MessageResult::Close
              return
            end

            # Important: clear the contents of the line, as it has just been processed.
            processed_index = 0
          else
            # Append current byte to processed line
            processed_line[processed_index] = byte
            processed_index += 1
          end

          index += 1
        end

        # Incomplete line remaining? Put it back in buffer.
        buffer += processed_line unless processed_index == 0

        break if !run_loop
      end
    end

    def self.ensure_start(stream)
      loop do
        read = stream.gets || ""

        if read == ""
          return ResultError::Closed
        end

        parts = read.split(" ")

        if parts.size >= 2 && parts.first.to_s.upcase == "START"
          if res_mode = parts[1]
            Log.debug {"got mode response: #{res_mode}"}

            if Mode.parse? res_mode
              # Check if authenticated?
              if !Caster.settings.auth_password.blank?
                provided_auth = parts[2]?

                # Compare provided password with configured password
                if provided_auth != Caster.settings.auth_password
                  Log.info { "password provided, but does not match" }
                  return ResultError::AuthenticationFailed
                end
              end

              return Mode.parse res_mode
            end
          end

          return ResultError::InvalidMode
        end

        return ResultError::NotRecognized
      end
    rescue IO::TimeoutError
      Log.info { "Timeout client" }
      return ResultError::Timeout
    end

  end
end
