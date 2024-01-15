require "../spec_helper"

Spectator.describe Executer::FlushO do
  include Executer

  describe ".execute" do
    let(collection) { "FlushO" }
    let(bucket) { "buck" }
    let(object) { "flusho_obj" }

    let(store) do
      Store::KVPool.acquire(Store::KVAcquireMode::Any, collection)
    end
    let(action) do
      Store::KVAction.new(bucket: bucket, store: store)
    end
    let(term) { 2_u32 }
    let(terms) { Set{term} }
    let(oid) { object }
    let(iid) { 1_u32 }

    let(item) { Store::Item.new collection: collection, bucket: bucket, object: object }

    before do
      action.set_iid_to_oid(iid, oid)
      action.set_term_to_iids(term, Set{iid})
      action.set_term_to_iids(term, Set{iid}, 1)
      action.set_oid_to_iid(oid, iid)
      action.set_iid_to_terms(iid, terms)
      action.set_iid_to_attrs(iid, UInt32[1, 0])
    end

    context "counts indexed terms" do

      it "returns terms removed" do

        expect(action.get_oid_to_iid(oid)).to eq iid
        expect(action.get_iid_to_terms(iid)).to eq terms
        expect(action.get_term_to_iids(term, 1)).to eq Set{iid}

        result = FlushO.execute item

        expect(result).to eq 2

        expect(action.get_iid_to_terms(iid)).to eq nil
        expect(action.get_term_to_iids(term)).to eq nil
        expect(action.get_term_to_iids(term, 1)).to eq nil
        expect(action.get_oid_to_iid(object)).to eq nil
        expect(action.get_iid_to_oid(iid)).to eq nil
        expect(action.get_iid_to_attrs(iid)).to eq nil

      end

    end

    context "iid to terms not found" do

      it "returns zero" do
        action.delete_iid_to_terms(iid)

        expect(action.get_iid_to_terms(iid)).to eq nil

        result = FlushO.execute item

        expect(result).to eq 0
      end
    end

    context "oid to iid not found" do

      it "returns zero" do
        action.delete_oid_to_iid(oid)

        expect(action.get_oid_to_iid(oid)).to eq nil

        result = FlushO.execute item

        expect(result).to eq 0
      end
    end
  end
end
