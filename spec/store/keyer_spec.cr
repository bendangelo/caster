require "../spec_helper"

Spectator.describe Store::Keyer do
  include Store

  describe ".meta_to_value" do
    it "keys meta to value" do
      result = Keyer.meta_to_value("bucket:1", 0).as_bytes

      expect(result).to eq(Bytes[0, 108, 244, 29, 93, 0, 0, 0, 0])
    end
  end

  describe ".term_to_iids" do
    it "keys term to iids" do
      result1 = Keyer.term_to_iids("bucket:2", 772137347).as_bytes
      result2 = Keyer.term_to_iids("bucket:2", 3582484684).as_bytes

      expect(result1).to eq(Bytes[10, 50, 220, 166, 65, 131, 225, 5, 46])
      expect(result2).to eq(Bytes[10, 50, 220, 166, 65, 204, 96, 136, 213])
    end

    it "keys term to iids with index" do
      result1 = Keyer.term_to_iids("bucket:2", 772137347, 1).as_bytes
      result2 = Keyer.term_to_iids("bucket:2", 3582484684, 1).as_bytes

      expect(result1).to eq(Bytes[11, 50, 220, 166, 65, 131, 225, 5, 46])
      expect(result2).to eq(Bytes[11, 50, 220, 166, 65, 204, 96, 136, 213])
    end
  end

  describe ".oid_to_iid" do
    it "keys oid to iid" do
      result = Keyer.oid_to_iid("bucket:3", "conversation:6501e83a").as_bytes

      expect(result).to eq(Bytes[1, 171, 194, 213, 57, 31, 156, 118, 213])
    end
  end

  describe ".iid_to_oid" do
    it "keys iid to oid" do
      result = Keyer.iid_to_oid("bucket:4", 10292198).as_bytes

      expect(result).to eq(Bytes[2, 105, 12, 54, 147, 230, 11, 157, 0])
    end
  end

  describe ".iid_to_terms" do
    it "keys iid to terms" do
      result1 = Keyer.iid_to_terms("bucket:5", 1).as_bytes
      result2 = Keyer.iid_to_terms("bucket:5", 20).as_bytes

      expect(result1).to eq(Bytes[3, 137, 142, 73, 67, 1, 0, 0, 0])
      expect(result2).to eq(Bytes[3, 137, 142, 73, 67, 20, 0, 0, 0])
    end
  end

  describe ".iid_to_attrs" do
    it "keys iid to attrs" do
      result1 = Keyer.iid_to_attrs("bucket:5", 1).as_bytes
      result2 = Keyer.iid_to_attrs("bucket:5", 20).as_bytes

      expect(result1).to eq(Bytes[4, 137, 142, 73, 67, 1, 0, 0, 0])
      expect(result2).to eq(Bytes[4, 137, 142, 73, 67, 20, 0, 0, 0])
    end
  end

    describe ".to_compact" do
      it "hashes compact" do
        result1 = Hasher.to_compact("key:1")
        result2 = Hasher.to_compact("key:2")

        expect(result1).to eq(3370353088)
        expect(result2).to eq(1042559698)
      end
  end

    describe ".format" do
      it "formats key" do
        result1 = Keyer.term_to_iids("bucket:6", 72137347)
        result2 = Keyer.meta_to_value("bucket:6", 0)

        expect(result1.as_bytes.size).to eq 9
        expect(result2.as_bytes.size).to eq 9

        expect(result1.to_s).to eq("10:498b1971:83ba4c04 Bytes[10, 73, 139, 25, 113, 131, 186, 76, 4]")
        expect(result2.to_s).to eq("0:498b1971:00000000 Bytes[0, 73, 139, 25, 113, 0, 0, 0, 0]")
      end
  end
end
