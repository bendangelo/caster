require "../spec_helper"

Spectator.describe Pipe::Message do
  include Pipe

  describe ".extract" do

    subject(extract) { Message.extract input }

    provided input: "PUSH test my data -- \"dsfdf\"" do
      expect(extract).to eq({"PUSH", %q[test my data -- "dsfdf"]})
    end

    provided input: "PUSH " do
      expect(extract).to eq({"PUSH", %q[]})
    end

    provided input: "PUSH    " do
      expect(extract).to eq({"PUSH", %q[]})
    end

  end

  describe ".handle_mode" do

    subject(handle_mode) { Message.handle_mode mode, message }

    provided mode: Mode::Ingest, message: %(PUSH {"collection": "test", "bucket": "my", "object": "data", "text": ""}) do
      expect(handle_mode).to eq CommandResult.new ResponseType::Err, value: "text is blank", error: CommandError::InvalidFormat
    end

    provided mode: Mode::Search, message: "PUSH not my command" do
      expect(handle_mode).to eq CommandResult.new ResponseType::Err, value: "command not found (PUSH)", error: CommandError::NotFound
    end

    provided mode: Mode::Search, message: "QUIT" do
      expect(handle_mode).to eq CommandResult.new ResponseType::Ended, "quit"
    end
  end
end
