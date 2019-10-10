SHELL=/bin/bash

BUILD := crystal build src/cli/bin/adgen.cr
DOCKER_BUILD := docker-compose run --rm crystal $(BUILD)

export UID = $(shell id -u)
export GID = $(shell id -g)

VERSION=
CURRENT_VERSION=$(shell git tag -l | sort -V | tail -1)
GUESSED_VERSION=$(shell git tag -l | sort -V | tail -1 | awk 'BEGIN { FS="." } { $$3++; } { printf "%d.%d.%d", $$1, $$2, $$3 }')

.SHELLFLAGS = -o pipefail -c

all: adgen-dev

.PHONY: adgen-dev
adgen-dev:
	$(BUILD) -o $@ --warnings none

.PHONY: adgen
adgen:
	$(BUILD) -o $@ -D with_pb --link-flags "-static" --release

.PHONY: adgen-pb
adgen-pb:
	$(BUILD) -o $@ -D with_pb

.PHONY : fbget
fbget:
	shards build fbget

.adgen-ruby-business-sdk:
	git clone --depth 2 git@github.com:adgen/adgen-ruby-business-sdk.git .adgen-ruby-business-sdk

.PHONY: gen
gen: gen-proto

.PHONY: gen-proto
gen-proto: .adgen-ruby-business-sdk
	@crystal gen/proto-adgen.cr

.PHONY: proto
proto:
	@mkdir -p src/proto
	protoc -I proto --crystal_out src/proto proto/*.proto
	@mkdir -p src/adgen/proto
	PROTOBUF_NS=Adgen::Proto protoc -I proto -I proto/adgen --crystal_out src/adgen/proto proto/adgen/*.proto

.PHONY : test
test: check_version_mismatch spec progs

.PHONY : spec
spec:
	crystal spec -v --fail-fast

.PHONY : check_version_mismatch
check_version_mismatch: shard.yml README.md
	diff -w -c <(grep version: README.md) <(grep ^version: shard.yml)

.PHONY : version
version:
	@if [ "$(VERSION)" = "" ]; then \
	  echo "ERROR: specify VERSION as bellow. (current: $(CURRENT_VERSION))";\
	  echo "  make version VERSION=$(GUESSED_VERSION)";\
	else \
	  sed -i -e 's/^version: .*/version: $(VERSION)/' shard.yml ;\
	  sed -i -e 's/^    version: [0-9]\+\.[0-9]\+\.[0-9]\+/    version: $(VERSION)/' README.md ;\
	  echo git commit -a -m "'$(COMMIT_MESSAGE)'" ;\
	  git commit -a -m 'version: $(VERSION)' ;\
	  git tag "v$(VERSION)" ;\
	fi

.PHONY : bump
bump:
	make version VERSION=$(GUESSED_VERSION) -s
