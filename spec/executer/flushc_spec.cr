require "../spec_helper"

Spectator.describe Executer::FlushC do
  include Executer

  describe ".execute" do
    let(collection) { "flushc" }
    let(bucket) { "buck" }
    let(object) { "flushc_obj" }

    let(store) do
      Store::KVPool.acquire(Store::KVAcquireMode::Any, collection)
    end
    let(action) do
      Store::KVAction.new(bucket: bucket, store: store)
    end
    let(terms) { Set.new UInt32[Store::Hasher.to_compact("hello"), Store::Hasher.to_compact("world")] }
    let(oid) { object }
    let(iid) { 1_u32 }

    let(item) { Store::Item.new collection: collection }

    before do
      action.set_iid_to_terms(iid, terms)
      action.set_iid_to_oid(iid, oid)
      action.set_oid_to_iid(oid, iid)
    end

    context "pool is open" do

      pre_condition do
        expect(action.get_oid_to_iid(oid)).to eq iid
        expect(action.get_iid_to_terms(iid)).to eq terms
      end

      post_condition do
        expect(Dir.exists? Store::KVBuilder.path collection).to eq false
        expect(Store::KVPool.find? collection).to eq nil
      end

      it "closes opened pools" do
        result = FlushC.execute item

        expect(result).to eq 1
      end

      it "deletes unopened pools" do
        expect(Store::KVPool.close collection).to eq true
        result = FlushC.execute item

        expect(result).to eq 1
      end

    end

    context "collection not found" do

      it "returns zero" do
        item = Store::Item.new "lala"

        result = FlushC.execute item
        expect(result).to eq 0
      end
    end
  end
end
