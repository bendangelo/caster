require "../spec_helper"

Spectator.describe Executer::Search do
  include Executer

  describe ".execute" do
    let(collection) { "executer_search" }
    # make a unique bucket for each spec
    let(bucket) { query.gsub " ", "_" }

    let(store) do
      Store::KVPool.acquire(Store::KVAcquireMode::Any, collection)
    end
    let(action) do
      Store::KVAction.new(bucket: bucket, store: store)
    end
    let(item) { Store::Item.new collection, bucket, nil }
    let(token) { Lexer::Token.new Lexer::TokenMode::NormalizeOnly, query, Lexer::Lang::Eng }
    let(limit) { 10 }
    let(offset) { 0 }
    let(oids) { {} of Symbol => String }
    let(attrs) { {} of Symbol => Array(UInt32) }
    let(query) { "" }
    let(greater_than) { nil }
    let(less_than) { nil }
    let(equal) { nil }

    before do

      oids.each do |k, v|
        v.split(" ").each_with_index do |w, i|
          if word = Lexer::Token.normalize(w)
            action.add_term_to_iid?(Store::Hasher.to_compact(word), k.to_i.to_u32, i.to_u8 + 1)
          end
        end

        action.set_iid_to_oid(k.to_i.to_u32, k.to_s)
      end

      attrs.each do |k, v|
        action.set_iid_to_attrs(k.to_i.to_u32, v)
      end
    end

    after do
      action.delete_iid_to_oid(:obj1.to_i.to_u32)
      action.delete_iid_to_attrs(:obj1.to_i.to_u32)
      action.delete_iid_to_oid(:obj2.to_i.to_u32)
      action.delete_iid_to_attrs(:obj2.to_i.to_u32)
      action.delete_iid_to_oid(:obj3.to_i.to_u32)
      action.delete_iid_to_attrs(:obj3.to_i.to_u32)
      action.delete_iid_to_oid(:obj4.to_i.to_u32)
      action.delete_iid_to_attrs(:obj4.to_i.to_u32)
      action.delete_iid_to_oid(:obj5.to_i.to_u32)
      action.delete_iid_to_attrs(:obj5.to_i.to_u32)
      action.delete_iid_to_oid(:obj6.to_i.to_u32)
      action.delete_iid_to_attrs(:obj6.to_i.to_u32)
    end

    subject(results) { Search.execute item, token, limit, offset, greater_than, less_than, equal }

    context "setup test" do

      provided query: "nothing in index" do
        result = Search.execute item, token, limit, offset
        expect(result.size).to eq 0
      end
    end

    context "gt, lt, eq" do

      provided less_than: {0_u32, 2_u32}, query: "fire", oids: {obj1: "today I say fire", obj2: "fire", obj3: "fire world"}, attrs: {obj1: [1.to_u32], obj2: [0.to_u32], obj3: [2.to_u32]} do
        expect(results).to eq ["obj2", "obj1"]
      end

      provided greater_than: {0_u32, 0_u32}, query: "fire", oids: {obj1: "today I say fire", obj2: "fire", obj3: "fire world"}, attrs: {obj1: [1.to_u32], obj2: [0.to_u32], obj3: [2.to_u32]} do
        expect(results).to eq ["obj3", "obj1"]
      end

      provided equal: {0_u32, 2_u32}, query: "fire", oids: {obj1: "today I say fire", obj2: "fire", obj3: "fire world"}, attrs: {obj1: [1.to_u32], obj2: [0.to_u32], obj3: [2.to_u32]} do
        expect(results).to eq ["obj3"]
      end

    end

    context "limit and offset" do

      provided offset: 0, limit: 2, query: "fire", oids: {obj1: "today I say fire", obj2: "fire", obj3: "fire world"} do
        result = Search.execute item, token, limit, offset
        expect(result).to eq ["obj2", "obj3"]
      end

      provided offset: 1, limit: 2, query: "fire", oids: {obj1: "today I say fire", obj2: "fire", obj3: "fire world"} do
        result = Search.execute item, token, limit, offset
        expect(result).to eq ["obj3", "obj1"]
      end

    end

    context "find matches with single term" do

      provided query: "hello", oids: {obj1: "today I say hello", obj2: "hello", obj3: "today my world"} do
        result = Search.execute item, token, limit, offset
        expect(result).to eq ["obj2", "obj1"]
      end

    end

    context "find matches with two terms" do
      provided query: "hello world", oids: {obj1: "unrelated text", obj2: "hello world - this something", obj3: "the hello world"} do
        result = Search.execute item, token, limit, offset
        expect(result).to eq ["obj2", "obj3"]
      end
    end

    context "ignores beginning terms if it is later in the query" do
      provided query: "Big hamburger store banner", oids: {obj1: "the hamburger", obj2: "store", obj3: "hamburger are made in a store over here", obj4: "banner over here"} do
        result = Search.execute item, token, limit, offset
        # expect(Search.debug).to eq ["obj3", "obj1"]
        expect(result).to eq ["obj3", "obj1"]
      end
    end

    context "matches with more query words ranked higher" do
      provided query: "Big hamburger store", oids: {obj1: "the hamburger", obj3: "hamburger are made in a store over here"} do
        result = Search.execute item, token, limit, offset
        expect(result).to eq ["obj3", "obj1"]
      end
    end

    context "orders matches by word index" do
      provided query: "toronto canada", oids: {obj1: "canada has toronto inside", obj2: "the toronto maple leafs canada", obj3: "toronto canada is great"} do
        result = Search.execute item, token, limit, offset
        expect(result).to eq ["obj3", "obj1", "obj2"]
      end

      provided query: "final fantasy", oids: {obj1: "fantasy final", obj2: "final the fantasy", obj3: "finals fantasy", obj4: "the final fantasy", obj5: "my best final making fantasy", obj6: "final fantasy 7"} do
        result = Search.execute item, token, limit, offset
        # expect(Search.debug).to eq ["obj3", "obj6", "obj2", "obj4", "obj5", "obj1"]
        expect(result).to eq ["obj3", "obj6", "obj1", "obj2", "obj4", "obj5"]
      end

    end
  end
end
