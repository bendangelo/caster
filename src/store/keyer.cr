module Store

  KEY_SIZE = 9
  MAX_TERM_INDEX_SIZE = 245

  alias KeyBytes = Slice(UInt8)
  alias KeyPrefix = Slice(UInt8)

  class Hasher
    def self.to_compact(part : String) : UInt32
      Xxhash::Hash32.hash part
    end
  end

  enum Idx
    # don't change order
    MetaToValue = 0 #(MetaKey),
    OIDToIID = 1#(ObjectOID),
    IIDToOID = 2#(ObjectIID),
    IIDToTerms = 3#(ObjectIID)
    IIDToAttrs = 4#(ObjectIID)
    # leave buffer for new entries
    TermToIIDs = 10#(TermHashed),
    # rest are for term indexes
  end

  struct Keyer
    key : KeyBytes

    def initialize(@key : KeyBytes)
    end

    def as_bytes : KeyBytes
      @key
    end

    def as_prefix : KeyPrefix
      # KeyPrefix format: [idx<1B> | bucket<4B>]
      @key[0, 5]
    end

    def to_s(io : IO)
      key_bucket = @key[1, 4].hexstring
      key_route = @key[5, 4].hexstring
      io << @key[0] << ":" << key_bucket << ":" << key_route << " " << @key
    end

    def self.meta_to_value(bucket : String, meta : UInt32) : Keyer
      route = meta

      Keyer.new(build_key(Idx::MetaToValue.value.to_u8, bucket, route))
    end

    def self.term_to_iids(bucket : String, term_hash : TermHash, index : UInt8 = 0) : Keyer
      route = term_hash

      Keyer.new(build_key(Idx::TermToIIDs.value.to_u8 + index, bucket, route))
    end

    def self.oid_to_iid(bucket : String, oid : String) : Keyer
      route = Hasher.to_compact oid

      Keyer.new(build_key(Idx::OIDToIID.value.to_u8, bucket, route))
    end

    def self.iid_to_oid(bucket : String, iid : UInt32) : Keyer

      Keyer.new(build_key(Idx::IIDToOID.value.to_u8, bucket, iid))
    end

    def self.iid_to_terms(bucket : String, iid : UInt32) : Keyer
      Keyer.new(build_key(Idx::IIDToTerms.value.to_u8, bucket, iid))
    end

    def self.iid_to_attrs(bucket : String, iid : UInt32) : Keyer
      Keyer.new(build_key(Idx::IIDToAttrs.value.to_u8, bucket, iid))
    end

    private def self.build_key(idx : UInt8, bucket : String, route : UInt32) : KeyBytes
      # Key format: [idx<1B> | bucket<4B> | route<4B>]

      # Generate final binary key
      io = IO::Memory.new KEY_SIZE
      # [idx<1B>]
      io.write_bytes(idx, IO::ByteFormat::LittleEndian)
      # [bucket<4B>]
      io.write_bytes(Hasher.to_compact(bucket), IO::ByteFormat::LittleEndian)
      # [route<4B>]
      io.write_bytes(route, IO::ByteFormat::LittleEndian)

      io.to_slice
    end

  end


end
