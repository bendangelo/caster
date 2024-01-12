require "../spec_helper"

Spectator.describe Executer::Count do
  include Executer

  describe ".execute" do
    let(collection) { "col" }
    let(bucket) { "buck" }
    let(object) { "count_obj" }

    let(store) do
      Store::KVPool.acquire(Store::KVAcquireMode::Any, collection)
    end
    let(action) do
      Store::KVAction.new(bucket: bucket, store: store)
    end
    let(terms) { Set.new UInt32[Store::Hasher.to_compact("hello"), Store::Hasher.to_compact("world")] }
    let(oid) { object }
    let(iid) { 1_u32 }

    describe "object" do

      let(item) { Store::Item.new collection, bucket, object }

      before do
        action.set_iid_to_terms(iid, terms)
        action.set_iid_to_oid(iid, oid)
        action.set_oid_to_iid(oid, iid)
      end

      context "counts indexed terms" do

        it "returns terms size" do
          expect(action.get_oid_to_iid(oid)).to eq iid
          expect(action.get_iid_to_terms(iid)).to eq terms

          result = Count.execute item
          expect(result).to eq terms.size
        end

      end

      context "object iid not found" do

        it "returns zero" do
          action.delete_oid_to_iid(oid)

          result = Count.execute item
          expect(result).to eq 0
        end
      end

      context "object terms not found" do

        it "returns zero" do
          action.delete_iid_to_terms(iid)

          result = Count.execute item
          expect(result).to eq 0
        end
      end
    end
  end
end
