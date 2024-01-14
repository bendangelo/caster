require "../spec_helper"

Spectator.describe Lexer::Token do
  include Lexer

  describe ".parse_text" do

    subject(extract) { Token.new(text: input, index_limit: index_limit.to_u8).parse_text }

    provided input: "banks banking bank is a bank", index_limit: UInt8::MAX do
      expect(extract).to eq ["bank", 1266403283, 0]
    end

    provided input: "banks stemming testing", index_limit: UInt8::MAX do
      expect(extract).to eq ["bank", 1266403283, 0, "stem", 4181876951, 1, "test", 1042293711, 2]
    end

    provided input: "hello tom where are you today in Paris?", index_limit: UInt8::MAX do
      expect(extract).to eq ["hello", 4211111929, 0, "tom", 4286168139, 1, "todai", 3321916932, 5, "pari", 875628256, 7]
    end

    provided input: "hello tom where are you today in Paris?", index_limit: 6 do
      expect(extract).to eq ["hello", 4211111929, 0, "tom", 4286168139, 1, "todai", 3321916932, 5, "pari", 875628256, 6]
    end

    provided input: "a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a tom hello", index_limit: UInt8::MAX do
      expect(extract).to eq ["tom", 4286168139, 255, "hello", 4211111929, 255]
    end

  end
end
