# caster

Text search engine

## Installation

```
curl -fsSL https://crystal-lang.org/install.sh | sudo bash
sudo apt-get -y install librocksdb-dev
curl -fsSLo- https://raw.githubusercontent.com/samueleaton/sentry/master/install.cr | crystal eval
./sentry
```

## Build

```
shards build --release
```

## Development

```
./sentry -r "crystal" --run-args "spec --debug" -w "./spec/**/*" -w "./src/**/*" 
```

## Deployment

```
ENV["CASTER_CONFIG"] = ./path/settings.yml
ENV["CASTER_PASSWORD"] = password
```

## Contributing

1. Fork it (<https://github.com/your-github-user/caster/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ben D'Angelo](https://github.com/your-github-user) - creator and maintainer
