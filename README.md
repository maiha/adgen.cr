# adgen.cr

adgen for [Crystal](http://crystal-lang.org/).

- crystal: 0.31.1

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  adgen:
    github: maiha/adgen.cr
```

2. Run `shards install`

## Usage

```crystal
require "adgen"

client = Adgen::Client.new(token: "xxxxxx")
res = client.get("/api/v2/report/performances")
puts res.body
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/maiha/adgen.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) - creator and maintainer
