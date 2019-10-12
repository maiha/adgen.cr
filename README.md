# adgen.cr [![Build Status](https://travis-ci.org/maiha/adgen.cr.svg?branch=master)](https://travis-ci.org/maiha/adgen.cr)

adgen for [Crystal](http://crystal-lang.org/).

- crystal: 0.31.1

## Usage (batch)

1. setup config

```console
$ adgen config sample > .adgenrc

$ vi .adgenrc
[api]
email      = "..."
password   = "..."

[batch]
publisher_ids   = [3]
```

2. run

```console
$ adgen batch run today
```

## Usage (lib)

### Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  adgen:
    github: maiha/adgen.cr
    version: 0.1.0
```

2. Run `shards install`

### example

```crystal
require "adgen"

# generate token
client = Adgen::Client.new
token  = client.authorize!("user.name@example.com", "password")
token.value # => "eyJ0..."

# call api
client = Adgen::Client.new(token: "xxxxxx") # "xxxxxx" is a token value
res = client.get("/api/v2/report/performances")
puts res.body
```

## Development

### test

```console
$ make test
```

### build

- Ubuntu 18.04.3 LTS
- libcurl.so.4

```console
$ make
```

## Contributing

1. Fork it (<https://github.com/maiha/adgen.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) - creator and maintainer
