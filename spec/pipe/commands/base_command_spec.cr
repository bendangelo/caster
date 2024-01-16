require "../../spec_helper"

Spectator.describe Pipe::BaseCommand do
  include Pipe

  describe ".parse_filter" do

    subject(command) { Pipe::BaseCommand.parse_filter input, key }

    provided input: "collection EQ 0,1 -- my text here".split(" "), key: "EQ" do
      expect(command).to eq({0, 1})
    end

    provided input: "collection EQ 0,1,0 -- my text here".split(" "), key: "EQ" do
      expect(command).to eq({0, 1})
    end

    provided input: "collection EQ 0e0 -- my text here".split(" "), key: "EQ" do
      expect(command).to eq(nil)
    end

    provided input: "collection EQ -- my text here".split(" "), key: "EQ" do
      expect(command).to eq(nil)
    end

    provided input: "collection 0e0 -- my text here".split(" "), key: "EQ" do
      expect(command).to eq(nil)
    end
  end

  describe ".parse_attrs" do

    subject(command) { Pipe::BaseCommand.parse_attrs input, key }

    provided input: ["ATTR", "0,1,2"], key: "ATTR" do
      expect(command).to eq([0, 1, 2])
    end

    provided input: ["ATTR", "{:limit=>1000,"], key: "ATTR" do
      expect(command).to eq([0, 0])
    end

    provided input: ["ATR", "0,1,2"], key: "ATTR" do
      expect(command).to eq(nil)
    end

    provided input: ["ATTR", "e"], key: "ATTR" do
      expect(command).to eq([0])
    end

    provided input: ["ATTR"], key: "ATTR" do
      expect(command).to eq(nil)
    end
  end

  describe ".parse_args_with_text" do

    subject(command) { Pipe::BaseCommand.parse_args_with_text input }

    provided input: "collection -- my text here" do
      expect(command).to eq({["collection"], "my text here"})
    end

    provided input: %q[collection bucket LANG eng -- hey this is -- cool \n] do
      expect(command).to eq({["collection", "bucket", "LANG", "eng"], "hey this is -- cool \n"})
    end

    provided input: "collection bucket -- " do
      expect(command).to eq({["collection", "bucket"], ""})
    end

    provided input: "" do
      expect(command).to eq({[""], ""})
    end

  end

  describe ".parse_args" do

    subject(command) { Pipe::BaseCommand.parse_args input }

    provided input: "collection here" do
      expect(command).to eq ["collection", "here"]
    end

  end

  describe ".parse_meta" do

    subject(command) { Pipe::BaseCommand.parse_meta input, key }

    provided input: ["LANG", "eng"], key: "LANG" do
      expect(command).to eq "eng"
    end

    provided input: ["OFF"], key: "OFF" do
      expect(command).to eq nil
    end

    provided input: [""], key: "OFF" do
      expect(command).to eq nil
    end

  end

  describe ".commit_result_operation" do
  end

  describe ".commit_ok_operation" do
  end

  describe ".commit_pending_operation" do
    # TODO: write commit pending op specs
  end
end
