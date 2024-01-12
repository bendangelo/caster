require "../../spec_helper"

Spectator.describe Pipe::IngestCommand do
  include Pipe

  describe ".dispatch_push" do

    subject(ingest) { Pipe::IngestCommand.dispatch_push parts }

    provided parts: "collection bucket object -- text" do
      expect(ingest.type).to eq ResponseType::Ok
    end

    provided parts: "collection bucket object LANG eng -- text eng" do
      expect(ingest.type).to eq ResponseType::Ok
    end

    context "invalid parts" do
      provided parts: "" do
        expect(ingest.type).to eq ResponseType::Err
      end

      provided parts: "collection" do
        expect(ingest.type).to eq ResponseType::Err
      end

      provided parts: "collection bucket" do
        expect(ingest.type).to eq ResponseType::Err
      end

      provided parts: "collection bucket obj" do
        expect(ingest.type).to eq ResponseType::Err
      end

      provided parts: "collection bucket obj -- " do
        expect(ingest.type).to eq ResponseType::Err
      end
    end

  end
end
