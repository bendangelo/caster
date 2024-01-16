require "../spec_helper"

Spectator.describe Lexer::Token do
  include Lexer

  describe ".parse_text" do

    subject(extract) { Token.new(text: input, index_limit: index_limit.to_u8).parse_text }

    provided input: "banks banking bank is a bank", index_limit: UInt8::MAX do
      expect(extract).to eq ["bank", 1266403283, 0]
    end

    provided input: "home? hey!", index_limit: UInt8::MAX do
      expect(extract).to eq ["home", 3801215962, 0, "hei", 3039456708, 1]
    end

    provided input: "re-move these's: 's & + ! @ # $ % ^ & * ( ) \\ | [ ] { } / ? ~ ` = - _ , . 🎄 £ tommy'humanity fff' 'fff don't", index_limit: UInt8::MAX do
      expect(extract).to eq ["re", 1398693813, 0, "move", 842472637, 1, "tommi", 2078988828, 5, "human", 3606118738, 6, "fff", 634594538, 7]
    end

    provided input: "5AM IN ＴＯＫＹＯ - Mellow chill ' jazz hip hop beats", index_limit: UInt8::MAX do
      expect(extract).to eq ["5am", 2488280076, 0, "mellow", 3790024579, 2, "chill", 1261417832, 3, "jazz", 3642901015, 4, "hip", 1563471963, 5, "hop", 841495740, 6, "beat", 3168828409, 7]
    end

    # keep periods, after split, remove so U.S. turns into US
    # provided input: "Pastors Get Involved Or U.S. Dies, Rev. Cook Says at Historic 1607 First Landing Event", index_limit: UInt8::MAX do
    #   expect(extract).to eq ["5am", 2488280076, 0, "mellow", 3790024579, 2, "chill", 1261417832, 3, "jazz", 3642901015, 4, "hip", 1563471963, 5, "hop", 841495740, 6, "beat", 3168828409, 7]
    # end

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
