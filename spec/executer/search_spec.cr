require "../spec_helper"

Spectator.describe Executer::Search do
  include Executer

  describe ".execute" do
    context "search for two terms with one object having both" do

      let(text) { "hello world" }
      let(collection) { "col" }
      let(bucket) { "buck" }
      let(object) { "obj" }

      let(store) do
        Store::KVPool.acquire(Store::KVAcquireMode::Any, collection)
      end
      let(action) do
        Store::KVAction.new(bucket: bucket, store: store)
      end
      let(event_id) { "eventid" }
      let(item) { Store::Item.new collection, bucket, nil }
      let(token) { Lexer::Token.new Lexer::TokenMode::NormalizeOnly, text, Lexer::Lang::Eng }
      let(limit) { 10 }
      let(offset) { 0 }
      let(iids) { Set.new UInt32[1] }
      let(oid) { "helloobject" }

      before do
        action.set_term_to_iids(Store::Hasher.to_compact("hello"), iids)
        action.set_term_to_iids(Store::Hasher.to_compact("world"), iids)
        action.set_iid_to_oid(1_u32, oid)
      end

      it "returns oid of wanted object" do
        result = Search.execute item, event_id, token, limit, offset
        expect(result.size).to eq 1
        expect(result[0]).to eq oid
      end

    end
  end
end
