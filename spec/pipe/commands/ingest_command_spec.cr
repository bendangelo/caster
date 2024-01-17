require "../../spec_helper"

Spectator.describe Pipe::IngestCommand do
  include Pipe

  describe ".dispatch_count" do

    subject(count) { Pipe::IngestCommand.dispatch_count parts }

    provided parts: "collection bucket object LANG eng -- text eng" do
      expect(count.type).to eq ResponseType::Err
    end

    provided parts: "collection bucket object" do
      expect(count.type).to eq ResponseType::Result
    end

    provided parts: "collection bucket object" do
      expect(count.type).to eq ResponseType::Result
    end

    provided parts: "collection bucket object" do
      expect(count.type).to eq ResponseType::Result
    end

  end

  describe ".dispatch_push" do

    subject(ingest) { Pipe::IngestCommand.dispatch_push parts }

    context "pushes data to kv" do

      let(collection) { "col" }
      let(bucket) { "dispatch_push" }
      let(object) { "push_obj" }
      let(keywords) { "" }
      let(attrs) { UInt32[0, 1] }

      let(store) do
        Store::KVPool.acquire(Store::KVAcquireMode::Any, collection)
      end
      let(action) do
        Store::KVAction.new(bucket: bucket, store: store)
      end

      let(parts) { %({"collection": "#{collection}", "bucket": "#{bucket}", "object": "#{object}", "text": "#{text}", "keywords": "#{keywords}"}) }

      provided text: "testing" do
        expect(ingest).to eq CommandResult.ok

        expect(action.get_iid_to_terms(1)).to eq Set.new UInt32[1042293711]
        expect(action.get_term_to_iids(Store::Hasher.to_compact("testing".stem))).to eq Set.new UInt32[1]
      end

      provided text: "hello world", keywords: "donald" do
        expect(ingest).to eq CommandResult.ok

        expect(action.get_term_to_iids(Store::Hasher.to_compact("hello".stem))).to eq Set.new UInt32[1]
        expect(action.get_term_to_iids(Store::Hasher.to_compact("donald".stem), 0)).to eq nil
        expect(action.get_term_to_iids(Store::Hasher.to_compact("donald".stem), Caster.settings.search.term_index_limit)).to eq Set.new UInt32[1]
      end
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
