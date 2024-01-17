require "spectator"
require "spectator/should"
require "../src/config/application"
require "./support/*"
require "file_utils"

Caster.boot true

Spectator.configure do |config|
  # config.fail_blank # Fail on no tests.
  # config.randomize  # Randomize test order.
  # config.profile    # Display slowest tests.
  config.fail_fast    # Display slowest tests.
  config.filter_run_when_matching :focus

  # config.before_all do
  #   ::Log.builder.clear
  #   backend = Log::IOBackend.new(STDOUT)
  #
  #   ::Log.builder.bind "*", Log::Severity.parse(Caster.settings.log_level), backend
  #   # ::Log.setup_from_env(default_level: :warn)
  # end

  config.before_suite do            # Runs a block of code before the test suite.

      # clear rocksdb
      Caster.settings.kv.path = "./data/tmp/"
      FileUtils.rm_rf("./data/tmp")
      FileUtils.mkdir("./data/tmp")
  end
end
