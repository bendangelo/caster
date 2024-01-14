require "option_parser"

OptionParser.parse do |parser|

  parser.on "-c", "--config=PATH", "Set config file path" do |path|
    # puts "given config path (#{path})"
    Caster::Settings.settings_path = path
  end

  parser.on "-v", "--version", "Show version" do
    puts "version #{Caster::VERSION}"
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end
