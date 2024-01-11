require "../spec_helper"

Spectator.describe Store::KVAction do
  include Store

  describe "#encode_u32" do

    subject { KVAction.encode_u32 input }

    provided input: 0_u32 do
      expect(subject).to eq Bytes[0, 0, 0, 0]
    end

    provided input: 1_u32 do
      expect(subject).to eq Bytes[1, 0, 0, 0]
    end

    provided input: 45402_u32 do
      expect(subject).to eq Bytes[90, 177, 0, 0]
    end
  end

  describe "#decode_u32" do
    subject { KVAction.decode_u32 input }

    provided input: Bytes[0, 0, 0, 0] do
      expect(subject).to eq 0
    end

    provided input: Bytes[1, 0, 0, 0] do
      expect(subject).to eq 1
    end

    provided input: Bytes[90, 177, 0, 0] do
      expect(subject).to eq 45402
    end
  end

  describe "#encode_u32_list" do
    subject { KVAction.encode_u32_list input }

    provided input: UInt32[0, 2, 3] do
      expect(subject).to eq Bytes[0, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0]
    end

    provided input: UInt32[45402] do
      expect(subject).to eq Bytes[90, 177, 0, 0]
    end
  end

  describe "#decode_u32_list" do
    subject { KVAction.decode_u32_list input }

    provided input: Bytes[0, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0] do
      expect(subject).to eq UInt32[0, 2, 3]
    end

    provided input: Bytes[90, 177, 0, 0] do
      expect(subject).to eq UInt32[45402]
    end
  end

  context "gets / sets / delete" do
    let(collection) { "videos" }
    let(bucket) { "all" }

    let(store) do
      Store::KVPool.acquire(Store::KVAcquireMode::Any, collection)
    end
    let(action) do
      Store::KVAction.new(bucket: bucket, store: store)
    end

    it "meta" do
      expect(action.get_meta_to_value(IIDIncr)).to eq nil
      expect(action.set_meta_to_value(IIDIncr, 1)).to eq nil
      expect(action.get_meta_to_value(IIDIncr)).to eq 1
    end

    it "term to iids" do
      expect( action.get_term_to_iids(1)).to eq nil
      expect( action.set_term_to_iids(1_u32, UInt32[0, 1, 2])).to eq nil
      expect( action.get_term_to_iids(1)).to eq UInt32[0, 1, 2]
      expect( action.delete_term_to_iids(1)).to eq nil
      expect( action.get_term_to_iids(1)).to eq nil
    end

    it "oid to iid" do
      expect( action.get_oid_to_iid("s")).to eq nil
      expect( action.set_oid_to_iid("s", 4)).to eq nil
      expect( action.get_oid_to_iid("s")).to eq 4
      expect( action.delete_oid_to_iid("s")).to eq nil
      expect( action.get_oid_to_iid("s")).to eq nil
    end

    it "iid to oid" do
      expect( action.get_iid_to_oid(4)).to eq nil
      expect( action.set_iid_to_oid(4, "s")).to eq nil
      expect( action.get_iid_to_oid(4)).to eq "s"
      expect( action.delete_iid_to_oid(4)).to eq nil
      expect( action.get_iid_to_oid(4)).to eq nil
    end

    it "iid to terms" do
      expect( action.get_iid_to_terms(4_u32)).to eq nil
      expect( action.set_iid_to_terms(4_u32, [45402_u32])).to eq nil
      expect( action.get_iid_to_terms(4_u32)).to eq UInt32[45402]
      expect( action.delete_iid_to_terms(4_u32)).to eq nil
      expect( action.get_iid_to_terms(4_u32)).to eq nil
    end
  end
end
