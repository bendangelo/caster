require "../spec_helper"

Spectator.describe Lexer::Token do
  include Lexer

  describe ".parse_text" do

    subject(extract) { Token.new(text: input).parse_text }

    provided input: "banks banking bank is a bank" do
      expect(extract).to eq ["bank", 1266403283, 0]
    end

    provided input: "banks stemming testing" do
      expect(extract).to eq ["bank", 1266403283, 0, "stem", 4181876951, 1, "test", 1042293711, 2]
    end

    provided input: "hello tom where are you today in Paris?" do
      expect(extract).to eq ["hello", 4211111929, 0, "tom", 4286168139, 1, "todai", 3321916932, 5, "pari", 875628256, 7]
    end

  end
end
