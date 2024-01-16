require "../../spec_helper"

Spectator.describe Pipe::SearchCommand do
  include Pipe

  describe ".dispatch_query" do

    subject(search) { SearchCommand.dispatch_query input }

    provided input: "dispatch_query bucket object -- text" do
      expect(search.type).to eq ResponseType::Err
    end

    provided input: %({"collection": "dispatch_query", "bucket": "but", "q": "testing"}) do
      expect(search).to eq(CommandResult.new ResponseType::Event, value: "QUERY")
    end

  end

end
