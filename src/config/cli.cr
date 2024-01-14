require "option_parser"

OptionParser.parse do |parser|

  parser.on "-c", "--config", "Set config file path" do |path|
    # bug, just take argv for now
    path = ARGV[1]
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
