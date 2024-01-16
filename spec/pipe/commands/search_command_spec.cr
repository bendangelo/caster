require "../../spec_helper"

Spectator.describe Pipe::SearchCommand do
  include Pipe

  describe ".dispatch_query" do

    subject(search) { SearchCommand.dispatch_query input }

    provided input: "dispatch_query bucket object -- text" do
      expect(search).to eq(CommandResult.new ResponseType::Event, value: "QUERY")
    end

    provided input: "dispatch_query bucket object GT 0,0 -- text" do
      expect(search).to eq(CommandResult.new ResponseType::Event, value: "QUERY")
    end

    provided input: "dispatch_query bucket object LT 0,0 -- text" do
      expect(search).to eq(CommandResult.new ResponseType::Event, value: "QUERY")
    end

    provided input: "dispatch_query bucket object EQ 0,0 -- text" do
      expect(search).to eq(CommandResult.new ResponseType::Event, value: "QUERY")
    end

    provided input: "dispatch_query bucket object ASC 0 -- text" do
      expect(search).to eq(CommandResult.new ResponseType::Event, value: "QUERY")
    end

    provided input: "dispatch_query bucket object DESC -- text" do
      expect(search).to eq(CommandResult.new ResponseType::Event, value: "QUERY")
    end
  end

end
