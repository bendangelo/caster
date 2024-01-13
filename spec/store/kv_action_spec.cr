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

  describe "#encode_u32_set" do
    subject { KVAction.encode_u32_set input }

    provided input: Set.new UInt32[0, 2, 3] do
      expect(subject).to eq Bytes[0, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0]
    end

    provided input: Set.new UInt32[45402] do
      expect(subject).to eq Bytes[90, 177, 0, 0]
    end
  end

  describe "#decode_u32_set" do
    subject { KVAction.decode_u32_set input }

    provided input: Bytes[0, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0] do
      expect(subject).to eq Set.new UInt32[0, 2, 3]
    end

    provided input: Bytes[90, 177, 0, 0] do
      expect(subject).to eq Set.new UInt32[45402]
    end
  end

  describe "#encode_u16_array" do
    subject { KVAction.encode_u16_array input }

    provided input: UInt16[0, 2, 3] do
      expect(subject).to eq Bytes[0, 0, 2, 0, 3, 0]
    end

    provided input: UInt16[45402] do
      expect(subject).to eq Bytes[90, 177]
    end
  end

  describe "#decode_u16_array" do
    subject { KVAction.decode_u16_array input }

    provided input: Bytes[0, 0, 2, 0, 3, 0] do
      expect(subject).to eq UInt16[0, 2, 3]
    end

    provided input: Bytes[90, 177] do
      expect(subject).to eq UInt16[45402]
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
      expect( action.set_term_to_iids(1_u32, Set.new UInt32[0, 1, 2])).to eq nil
      expect( action.get_term_to_iids(1)).to eq Set.new UInt32[0, 1, 2]
      expect( action.delete_term_to_iids(1)).to eq true
      expect( action.get_term_to_iids(1)).to eq nil
    end

    it "oid to iid" do
      expect( action.get_oid_to_iid("s")).to eq nil
      expect( action.set_oid_to_iid("s", 4)).to eq nil
      expect( action.get_oid_to_iid("s")).to eq 4
      expect( action.delete_oid_to_iid("s")).to eq true
      expect( action.get_oid_to_iid("s")).to eq nil
    end

    it "iid to oid" do
      expect( action.get_iid_to_oid(4)).to eq nil
      expect( action.set_iid_to_oid(4, "s")).to eq nil
      expect( action.get_iid_to_oid(4)).to eq "s"
      expect( action.delete_iid_to_oid(4)).to eq true
      expect( action.get_iid_to_oid(4)).to eq nil
    end

    it "iid to terms" do
      expect( action.get_iid_to_terms(4_u32)).to eq nil
      expect( action.set_iid_to_terms(4_u32, Set.new [45402_u32])).to eq nil
      expect( action.get_iid_to_terms(4_u32)).to eq Set.new UInt32[45402]
      expect( action.delete_iid_to_terms(4_u32)).to eq true
      expect( action.get_iid_to_terms(4_u32)).to eq nil
    end

    it "iid to attrs" do
      iid = 4_u32
      expect( action.get_iid_to_attrs(iid)).to eq nil
      expect( action.set_iid_to_attrs(iid, UInt16[45402_u16])).to eq nil
      expect( action.get_iid_to_attrs(iid)).to eq UInt16[45402]
      expect( action.delete_iid_to_attrs(iid)).to eq true
      expect( action.get_iid_to_attrs(iid)).to eq nil
    end
  end

  describe "#batch_erase_bucket" do
    let(collection) { "videos" }
    let(bucket) { "all" }

    let(store) do
      Store::KVPool.acquire(Store::KVAcquireMode::Any, collection)
    end
    let(action) do
      Store::KVAction.new(bucket: bucket, store: store)
    end

    before do
      action.set_meta_to_value(IIDIncr, 1)
      action.set_term_to_iids(1_u32, Set{1_u32})
      action.set_oid_to_iid("10", 1)
      action.set_iid_to_oid(1_u32, "10")
      action.set_iid_to_terms(1_u32, Set{1_u32})
    end

    it "clears bucket" do
      # expect(action.batch_erase_bucket).to eq nil
      #
      # expect(action.get_meta_to_value(IIDIncr)).to eq nil
      # expect(action.get_term_to_iids(1_u32)).to eq nil
      # expect(action.get_oid_to_iid("10")).to eq nil
      # expect(action.get_iid_to_oid(1_u32)).to eq nil
      # expect(action.get_iid_to_terms(1_u32)).to eq nil

    end
  end

  describe "#batch_flush_bucket" do
    let(collection) { "videos" }
    let(bucket) { "all" }
    let(object) { "testobj" }
    let(iid) { 1_u32 }
    let(term) { 2_u32 }
    let(other_iid) { 4_u32 }

    let(store) do
      Store::KVPool.acquire(Store::KVAcquireMode::Any, collection)
    end
    let(action) do
      Store::KVAction.new(bucket: bucket, store: store)
    end

    before do
      action.set_oid_to_iid(object, iid)
      action.set_iid_to_oid(iid, object)
      action.set_iid_to_terms(iid, Set{term})
      action.set_term_to_iids(term, Set{iid})
    end

    it "deletes term to iids" do

      expect(action.get_term_to_iids(term)).to eq Set{iid}

      expect(action.batch_flush_bucket(iid, object, Set{term})).to eq 1

      expect(action.get_term_to_iids(term)).to eq nil
      expect(action.get_oid_to_iid(object)).to eq nil
      expect(action.get_iid_to_oid(iid)).to eq nil
      expect(action.get_iid_to_terms(iid)).to eq nil

    end

    it "keeps terms for other iids" do
      action.set_term_to_iids(term, Set{iid, other_iid})

      expect(action.batch_flush_bucket(iid, object, Set{term})).to eq 1

      expect(action.get_term_to_iids(term)).to eq Set{other_iid}
    end
  end
end
