#!/usr/bin/make -f

PACKAGES_SIMTEST=$(shell go list ./... | grep '/simulation')
VERSION := $(shell echo $(shell git describe --tags) | sed 's/^v//')
COMMIT := $(shell git log -1 --format='%H')
LEDGER_ENABLED ?= true
SDK_PACK := $(shell go list -m github.com/libonomy/cusp-sdk | sed  's/ /\@/g')

export GO111MODULE = on

# process build tags

build_tags = netgo
ifeq ($(LEDGER_ENABLED),true)
  ifeq ($(OS),Windows_NT)
    GCCEXE = $(shell where gcc.exe 2> NUL)
    ifeq ($(GCCEXE),)
      $(error gcc.exe not installed for ledger support, please install or set LEDGER_ENABLED=false)
    else
      build_tags += ledger
    endif
  else
    UNAME_S = $(shell uname -s)
    ifeq ($(UNAME_S),OpenBSD)
      $(warning OpenBSD detected, disabling ledger support (https://github.com/libonomy/cusp-sdk/issues/1988))
    else
      GCC = $(shell command -v gcc 2> /dev/null)
      ifeq ($(GCC),)
        $(error gcc not installed for ledger support, please install or set LEDGER_ENABLED=false)
      else
        build_tags += ledger
      endif
    endif
  endif
endif

ifeq ($(WITH_CLEVELDB),yes)
  build_tags += gcc
endif
build_tags += $(BUILD_TAGS)
build_tags := $(strip $(build_tags))

whitespace :=
whitespace += $(whitespace)
comma := ,
build_tags_comma_sep := $(subst $(whitespace),$(comma),$(build_tags))

# process linker flags

ldflags = -X github.com/libonomy/cusp-sdk/version.Name=cusp \
		  -X github.com/libonomy/cusp-sdk/version.ServerName=cuspd \
		  -X github.com/libonomy/cusp-sdk/version.ClientName=cuspcli \
		  -X github.com/libonomy/cusp-sdk/version.Version=$(VERSION) \
		  -X github.com/libonomy/cusp-sdk/version.Commit=$(COMMIT) \
		  -X "github.com/libonomy/cusp-sdk/version.BuildTags=$(build_tags_comma_sep)"

ifeq ($(WITH_CLEVELDB),yes)
  ldflags += -X github.com/libonomy/cusp-sdk/types.DBBackend=cleveldb
endif
ldflags += $(LDFLAGS)
ldflags := $(strip $(ldflags))

BUILD_FLAGS := -tags "$(build_tags)" -ldflags '$(ldflags)'

# The below include contains the tools target.
include contrib/devtools/Makefile

all: install lint check

build: go.sum
ifeq ($(OS),Windows_NT)
	go build -mod=readonly $(BUILD_FLAGS) -o build/cuspd.exe ./cmd/cuspd
	go build -mod=readonly $(BUILD_FLAGS) -o build/cuspcli.exe ./cmd/cuspcli
else
	go build -mod=readonly $(BUILD_FLAGS) -o build/cuspd ./cmd/cuspd
	go build -mod=readonly $(BUILD_FLAGS) -o build/cuspcli ./cmd/cuspcli
endif

build-linux: go.sum
	LEDGER_ENABLED=false GOOS=linux GOARCH=amd64 $(MAKE) build

install: go.sum
	go install -mod=readonly $(BUILD_FLAGS) ./cmd/cuspd
	go install -mod=readonly $(BUILD_FLAGS) ./cmd/cuspcli

install-debug: go.sum
	go install -mod=readonly $(BUILD_FLAGS) ./cmd/cuspdebug

########################################
### Tools & dependencies

go-mod-cache: go.sum
	@echo "--> Download go modules to local cache"
	@go mod download

go.sum: go.mod
	@echo "--> Ensure dependencies have not been modified"
	@go mod verify

draw-deps:
	@# requires brew install graphviz or apt-get install graphviz
	go get github.com/RobotsAndPencils/goviz
	@goviz -i ./cmd/cuspd -d 2 | dot -Tpng -o dependency-graph.png

clean:
	rm -rf snapcraft-local.yaml build/

distclean: clean
	rm -rf vendor/

########################################
########################################
### Local validator nodes using docker and docker-compose

build-docker-cuspdnode:
	$(MAKE) -C networks/local
	
# Run a 4-node testnet locally
localnet-start: build-linux localnet-stop
	@if ! [ -f build/node0/cuspd/config/genesis.json ]; then docker run --rm -v $(CURDIR)/build:/cuspd:Z libonomy/cuspdnode testnet --v 4 -o . --starting-ip-address 192.168.10.2 ; fi
	docker-compose up -d

# Stop testnet
localnet-stop:
	docker-compose down

# include simulations
include sims.mk

.PHONY: all build-linux install install-debug \
	go-mod-cache draw-deps clean build \
	setup-transactions setup-contract-tests-data start-cusp run-lcd-contract-tests contract-tests \
	test test-all test-build test-cover test-unit test-race
