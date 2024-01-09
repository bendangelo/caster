require "../../spec_helper"

Spectator.describe Pipe::BaseCommand do
  include Pipe

  describe ".parse_text_parts" do

    subject(command) { Pipe::BaseCommand.parse_text_parts parts }

    provided parts: [%["hey], "bucket", "object", %[\"text"]] do
      expect(command).to eq %[hey bucket object "text]
    end

    provided parts: [%["hey], "bucket", "object", %[\"text"], "meta data"] do
      expect(command).to eq %[hey bucket object "text]
    end

    provided parts: [%[hey], %[text"]] do
      expect(command).to eq nil
    end

    provided parts: [%["], %["]] do
      expect(command).to eq nil
    end

  end

  describe ".parse_next_meta_parts" do

    # subject(ingest) { Pipe::IngestCommand.dispatch_push parts }
    #
    # provided parts: ["collection", "bucket", "object", %["text"]] do
    # end
  end
end
