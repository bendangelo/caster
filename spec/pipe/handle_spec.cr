require "../spec_helper"

Spectator.describe Pipe::Handle do
  include Pipe

  let(run_loop) { false }
  double :tcpsocket, gets: ""

  describe ".ensure_start" do

    before_each do
      Caster.settings.auth_password = ""
    end

    after_each do
      Caster.settings.auth_password = ""
    end

    subject do
      Handle.ensure_start(double :tcpsocket, gets: gets_input)
    end

    context "with password" do

      before_each do
        Caster.settings.auth_password = "hello"
      end

      subject { Handle.ensure_start(double :tcpsocket, gets: gets_input) }

      provided gets_input: "START search" do
        expect(Caster.settings.auth_password).to eq "hello"
        expect(subject).to eq ResultError::AuthenticationFailed
      end

      provided gets_input: "START search sdsd" do
        expect(Caster.settings.auth_password).to eq "hello"
        expect(subject).to eq ResultError::AuthenticationFailed
      end

      provided gets_input: "START search hello" do
        expect(Caster.settings.auth_password).to eq "hello"
        expect(subject).to eq Mode::Search
      end

      context "with password from env" do

        before_each do
          ENV["CASTER_PASSWORD"] = "testing"
          Caster.settings.auth_password = ""
          Caster::Settings.load_from_env!
        end

        provided gets_input: "START search testing" do
          expect(Caster.settings.auth_password).to eq "testing"
          expect(subject).to eq Mode::Search
        end
      end

    end

    context "with io timeout" do

      double :error_tcpsocket, gets: ""

      subject do
        db = double :error_tcpsocket
        allow(db).to receive(:gets).and_raise IO::TimeoutError
        Handle.ensure_start(db)
      end

      provided gets_input: "START search hello" do
        expect(subject).to eq ResultError::Timeout
      end
    end

    provided gets_input: "START search hello" do
      expect(subject).to eq Mode::Search
    end

    provided gets_input: "" do
      expect(subject).to eq ResultError::Closed
    end

    provided gets_input: "START ingest" do
      expect(subject).to eq Mode::Ingest
    end

    provided gets_input: "START control" do
      expect(subject).to eq Mode::Control
    end

    provided gets_input: "START asdasd" do
      expect(subject).to eq ResultError::InvalidMode
    end

    provided gets_input: "START" do
      expect(subject).to eq ResultError::NotRecognized
    end

    provided gets_input: "asdf" do
      expect(subject).to eq ResultError::NotRecognized
    end

  end

  describe ".handle_stream" do

    # short for testing
    let(max_line_size) { 50 }

    context "bulk messages" do

      double :tcpsocket, gets_input: "PING\nQUIT\n", puts: nil do
          stub def read(buffer)
            slice = gets_input.to_unsafe.to_slice(gets_input.size)

            slice.copy_to buffer

            gets_input.size
          end
      end

      let(tcpsocket) { double(:tcpsocket) }

      it "pongs then puts quits" do
        expect(tcpsocket).to receive(:puts).with("PONG#{Handle::LINE_FEED}")
        expect(tcpsocket).to receive(:puts).with("ENDED quit#{Handle::LINE_FEED}")

        Handle.handle_stream(Mode::Search, tcpsocket, max_line_size, run_loop)
      end
    end

    context "PING sent" do

      double :tcpsocket, gets_input: "PING\n", puts: nil do
          stub def read(buffer)
            slice = gets_input.to_unsafe.to_slice(gets_input.size)

            slice.copy_to buffer

            gets_input.size
          end
      end

      let(tcpsocket) { double(:tcpsocket) }

      it "pongs without extra space" do
        expect(tcpsocket).to receive(:puts).with("PONG#{Handle::LINE_FEED}")

        Handle.handle_stream(Mode::Search, tcpsocket, max_line_size, run_loop)
      end
    end

    context "QUERY sent" do

      double :tcpsocket, gets_input: %[QUERY messages user:1 "hello"\n], puts: nil do
          stub def read(buffer)
            slice = gets_input.to_unsafe.to_slice(gets_input.size)

            slice.copy_to buffer

            gets_input.size
          end
      end

      let(tcpsocket) { double(:tcpsocket) }

      it "returns pending and then event" do
        expect(tcpsocket).to receive(:puts).with(/PENDING [A-za-z=0-9+\-]+#{Handle::LINE_FEED}/)
        expect(tcpsocket).to receive(:puts).with(/EVENT QUERY [A-za-z=0-9+\-]+#{Handle::LINE_FEED}/)

        Handle.handle_stream(Mode::Search, tcpsocket, max_line_size, run_loop)
      end
    end

    context "QUIT sent" do

      double :tcpsocket, gets_input: "QUIT\n", puts: nil do
          stub def read(buffer)
            slice = gets_input.to_unsafe.to_slice(gets_input.size)

            slice.copy_to buffer
            gets_input.size
          end
      end

      let(tcpsocket) { double(:tcpsocket) }

      it "quits" do
        expect(tcpsocket).to receive(:puts).with("ENDED quit#{Handle::LINE_FEED}")

        Handle.handle_stream(Mode::Search, tcpsocket, max_line_size, run_loop)
      end
    end

    context "buffer too long" do

      let(max_line_size) { 4 }

      double :overflow_tcpsocket, read: 4, puts: nil do
      end

      let(overflow_tcpsocket) { double(:overflow_tcpsocket) }

      provided gets_input: "asdf" do
        expect(overflow_tcpsocket).to receive(:puts).with("ERR BufferOverflow#{Handle::LINE_FEED}")

        Handle.handle_stream(Mode::Search, overflow_tcpsocket, max_line_size)
      end
    end
  end

  describe ".client" do

    context "connets to search mode" do
      # TODO: add client specs
      # double :tcpsocket, gets: "START search", puts: nil, read: 0, tcp_nodelay: false
      #
      # let(tcpsocket) { double(:tcpsocket) }
      #
      # it "quits" do
      #   Caster.settings.auth_password = ""
      #   expect(tcpsocket).to receive(:tcp_nodelay).with(true)
      #   expect(tcpsocket).to receive(:puts).with("#{Handle::CONNECTED_BANNER}#{Handle::LINE_FEED}")
      #   expect(tcpsocket).to receive(:puts).with("ENDED exit#{Handle::LINE_FEED}")
      #
      #   Handle.client(tcpsocket, run_loop)
      # end
    end
  end
end
