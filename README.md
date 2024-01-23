# caster

Text search engine

## Installation

```
# Clone RocksDB
git clone https://github.com/facebook/rocksdb.git && cd rocksdb

# Build RocksDB
DEBUG_LEVEL=0 make shared_lib

# Install RocksDB so that Desmos can access it
sudo make install-shared

# Make sure the newly built library is linked correctly
sudo ldconfig

curl -fsSL https://crystal-lang.org/install.sh | sudo bash
curl -fsSLo- https://raw.githubusercontent.com/samueleaton/sentry/master/install.cr | crystal eval
./sentry
```

## Build

```
shards build --release
```

## Development

For auto running specs:

```
./sentry -r "crystal" --run-args "spec --debug" -w "./spec/**/*" -w "./src/**/*" 
```

```
ENV["CASTER_CONFIG"] = ./path/settings.yml
ENV["CASTER_PASSWORD"] = password

shards build --release -Dpreview_mt
./bin/caster CRYSTAL_WORKERS=4 # number of cpu cores
```

## Deployment

```
docker buildx build --platform linux/arm64 -t registry.gitlab.com/bendangelo/caster:1.0.0 .
docker push registry.gitlab.com/bendangelo/caster
```

## Contributing

1. Fork it (<https://github.com/your-github-user/caster/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ben D'Angelo](https://github.com/your-github-user) - creator and maintainer
