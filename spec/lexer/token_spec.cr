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

    provided input: "hello where are you today?" do
      expect(extract).to eq ["hello", 4211111929, 0, "todai", 3321916932, 4]
    end

  end
end
