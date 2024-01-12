require "../spec_helper"

Spectator.describe Pipe::Utils do
  include Pipe

  describe ".unescape" do
    it "unescapes command text" do
      Utils.unescape("hello world!").should eq "hello world!"
      Utils.unescape("i'm so good at this").should eq "i'm so good at this"
      Utils.unescape(%[look at me i'm " trying to hack you]).should eq %[look at me i'm " trying to hack you]
      Utils.unescape(%[look at me i'm \\" trying to hack you]).should eq %[look at me i'm \\" trying to hack you]

      Utils.unescape(%[hi\\nhi]).should eq %[hi\nhi]
      Utils.unescape(%[hi\\]).should eq %[hi\\]

      Utils.unescape(%[look at \\\"\\" me i'm \""trying to hack you"]).should eq %[look at \\\"\\" me i'm \""trying to hack you"]
    end
  end
end
