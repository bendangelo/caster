require "option_parser"

OptionParser.parse do |parser|
  parser.banner = "Welcome to Caster!"

  parser.on "-v", "--version", "Show version" do
    puts "version 1.0"
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end
