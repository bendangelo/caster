require "../src/config/application"
require "./support/*"
require "spectator"
require "spectator/should"
require "file_utils"

Caster.boot true

# clear rocksdb
Caster.settings.kv.path = "./data/tmp/"
FileUtils.rm_rf("./data/tmp")
FileUtils.mkdir("./data/tmp")

Spectator.configure do |config|
  # config.fail_blank # Fail on no tests.
  # config.randomize  # Randomize test order.
  # config.profile    # Display slowest tests.
  config.fail_fast    # Display slowest tests.
end
