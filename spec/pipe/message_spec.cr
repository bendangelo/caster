require "../spec_helper"

Spectator.describe Pipe::Message do
  include Pipe

  describe ".extract" do

    subject(extract) { Message.extract input }

    provided input: "PUSH test my data \"dsfdf\"" do
      expect(extract).to eq({"PUSH", %q[test my data "dsfdf"]})
    end

    provided input: "PUSH " do
      expect(extract).to eq({"PUSH", %q[]})
    end

    provided input: "PUSH    " do
      expect(extract).to eq({"PUSH", %q[]})
    end

  end
end
