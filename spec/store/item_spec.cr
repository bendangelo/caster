
  #
  # # # Tests
  # # describe StoreItemBuilder do
  # #   it "builds Store::Item depth 1" do
  # #     expect(StoreItemBuilder.from_depth_1("c:test:1")).to eq Ok(Store::Item.new(StoreItemPart.new("c:test:1"), nil, nil))
  # #     expect(StoreItemBuilder.from_depth_1("")).to eq Err(StoreItemError::InvalidCollection)
  # #   end
  # #
  # #   it "builds Store::Item depth 2" do
  # #     expect(StoreItemBuilder.from_depth_2("c:test:2", "b:test:2")).to eq Ok(Store::Item.new(StoreItemPart.new("c:test:2"), StoreItemPart.new("b:test:2"), nil))
  # #     expect(StoreItemBuilder.from_depth_2("", "b:test:2")).to eq Err(StoreItemError::InvalidCollection)
  # #     expect(StoreItemBuilder.from_depth_2("c:test:2", "")).to eq Err(StoreItemError::InvalidBucket)
  # #   end
  # #
  # #   it "builds Store::Item depth 3" do
  # #     expect(StoreItemBuilder.from_depth_3("c:test:3", "b:test:3", "o:test:3")).to eq Ok(Store::Item.new(StoreItemPart.new("c:test:3"), StoreItemPart.new("b:test:3"), StoreItemPart.new("o:test:3")))
  # #     expect(StoreItemBuilder.from_depth_3("", "b:test:3", "o:test:3")).to eq Err(StoreItemError::InvalidCollection)
  # #     expect(StoreItemBuilder.from_depth_3("c:test:3", "", "o:test:3")).to eq Err(StoreItemError::InvalidBucket)
  # #     expect(StoreItemBuilder.from_depth_3("c:test:3", "b:test:3", "")).to eq Err(StoreItemError::InvalidObject)
  # #   end
  # # end
