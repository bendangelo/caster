module Store
#   struct StoreKeyer
#     key : StoreKeyerKey
#   end
#
#   struct StoreKeyerHasher
#   end
#
#   enum StoreKeyerIdx
#     MetaToValue(StoreMetaKey),
#       TermToIIDs(StoreTermHashed),
#       OIDToIID(StoreObjectOID),
#       IIDToOID(StoreObjectIID),
#       IIDToTerms(StoreObjectIID)
#   end
#
#   type StoreKeyerKey = Bytes[9]
#   type StoreKeyerPrefix = Bytes[5]
#
#   module StoreKeyerIdx
#     def to_index : UInt8
#       case self
#       when MetaToValue
#         0
#       when TermToIIDs
#         1
#       when OIDToIID
#         2
#       when IIDToOID
#         3
#       when IIDToTerms
#         4
#       end
#     end
#   end
#
#   struct StoreKeyerBuilder
#   end
#
#   impl StoreKeyerIdx
#   def self.to_compact(part : String) : UInt32
#     hasher = XXHash32.new(0)
#     hasher << part
#     hasher.digest
#   end
# end
#
# impl StoreKeyerBuilder
# def self.meta_to_value(bucket : String, meta : StoreMetaKey) : StoreKeyer
#   make(StoreKeyerIdx::MetaToValue(meta), bucket)
# end
#
# def self.term_to_iids(bucket : String, term_hash : StoreTermHashed) : StoreKeyer
#   make(StoreKeyerIdx::TermToIIDs(term_hash), bucket)
# end
#
# def self.oid_to_iid(bucket : String, oid : StoreObjectOID) : StoreKeyer
#   make(StoreKeyerIdx::OIDToIID(oid), bucket)
# end
#
# def self.iid_to_oid(bucket : String, iid : StoreObjectIID) : StoreKeyer
#   make(StoreKeyerIdx::IIDToOID(iid), bucket)
# end
#
# def self.iid_to_terms(bucket : String, iid : StoreObjectIID) : StoreKeyer
#   make(StoreKeyerIdx::IIDToTerms(iid), bucket)
# end
#
# private def self.make(idx : StoreKeyerIdx, bucket : String) : StoreKeyer
#   StoreKeyer.new(key: build_key(idx, bucket))
# end
#
# private def self.build_key(idx : StoreKeyerIdx, bucket : String) : StoreKeyerKey
#   # Key format: [idx<1B> | bucket<4B> | route<4B>]
#
#   # Encode key bucket + key route from UInt32 to array of UInt8 (ie. binary)
#   bucket_encoded = Bytes[UInt8].new.tap { |b| b.write_u32_le!(StoreKeyerHasher.to_compact(bucket)) }
#   route_encoded = Bytes[UInt8].new.tap { |b| b.write_u32_le!(route_to_compact(idx)) }
#
#   # Generate final binary key
#   Bytes[UInt8].new([
#     # [idx<1B>]
#     idx.to_index,
#     # [bucket<4B>]
#     *bucket_encoded,
#     # [route<4B>]
#     *route_encoded,
#   ])
# end
#
# private def self.route_to_compact(idx : StoreKeyerIdx) : UInt32
#   case idx
#   when MetaToValue
#     idx.meta.as_u32
#   when TermToIIDs
#     idx.term_hash
#   when OIDToIID
#     StoreKeyerHasher.to_compact(idx.oid)
#   when IIDToOID
#     idx.iid
#   when IIDToTerms
#     idx.iid
#   end
# end
# end
#
# impl StoreKeyer
# def as_bytes : StoreKeyerKey
#   @key
# end
#
# def as_prefix : StoreKeyerPrefix
#   # Prefix format: [idx<1B> | bucket<4B>]
#   @key[0, 5]
# end
# end
#
# impl StoreKeyerHasher
# def self.to_compact(part : String) : UInt32
#   hasher = XXHash32.new(0)
#   hasher << part
#   hasher.digest
# end
# end
#
# # Displaying StoreKeyer
# def show(io : IO, keyer : StoreKeyer)
#   key_bucket = keyer.key[1, 4].to_slice(UInt32).read_u32_le
#   key_route = keyer.key[5, 4].to_slice(UInt32).read_u32_le
#   io << "'#{keyer.key[0].to_s}#{key_bucket.to_s(16)}:#{key_route.to_s(16)}' #{keyer.key.to_s}"
# end
end
