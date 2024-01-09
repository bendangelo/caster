module Store

  record Item, collection : ItemPart, bucket : ItemPart?, object : ItemPart?

  struct ItemPart
    value : String

    def initialize(@value : String)
    end

    def self.from_str(part : String)
      len = part.size

      if len > STORE_ITEM_PART_LEN_MIN && len <= STORE_ITEM_PART_LEN_MAX && part.ascii_only?
        ItemPart.new(part)
      else
        nil
      end
    end

    def as_str : String
      @value
    end
  end

  enum ItemError
    InvalidCollection
    InvalidBucket
    InvalidObject
  end

  STORE_ITEM_PART_LEN_MIN = 0
  STORE_ITEM_PART_LEN_MAX = 128

  module ItemBuilder
    def self.from_depth_1(collection : String)
      # Validate & box collection
      if (collection_item = ItemPart.from_str(collection))
        Item.new(collection_item, nil, nil)
      else
        ItemError::InvalidCollection
      end
    end

    def self.from_depth_2(collection : String, bucket : String)
      # Validate & box collection + bucket
      if (collection_item = ItemPart.from_str(collection)) &&
          (bucket_item = ItemPart.from_str(bucket))
        Item.new(collection_item, bucket_item, nil)
      elsif collection_item.nil?
        ItemError::InvalidCollection
      else
        ItemError::InvalidBucket
      end
    end

    def self.from_depth_3(collection : String, bucket : String, object : String)
      # Validate & box collection + bucket + object
      if (collection_item = ItemPart.from_str(collection)) &&
          (bucket_item = ItemPart.from_str(bucket)) &&
          (object_item = ItemPart.from_str(object))
        Item.new(collection_item, bucket_item, object_item)
      elsif collection_item.nil?
        ItemError::InvalidCollection
      elsif bucket_item.nil?
        ItemError::InvalidBucket
      else
        ItemError::InvalidObject
      end
    end
  end
end
