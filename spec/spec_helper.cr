require "../src/config/application"
require "./support/*"
require "spectator"
require "spectator/should"

Caster.boot

Spectator.configure do |config|
  # config.fail_blank # Fail on no tests.
  # config.randomize  # Randomize test order.
  # config.profile    # Display slowest tests.
  config.fail_fast    # Display slowest tests.
end
