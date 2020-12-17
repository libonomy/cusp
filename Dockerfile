# Simple usage with a mounted data directory:
# > docker build -t cusp .
# > docker run -it -p 46657:46657 -p 46656:46656 -v ~/.cuspd:/root/.cuspd -v ~/.cuspcli:/root/.cuspcli cusp cuspd init
# > docker run -it -p 46657:46657 -p 46656:46656 -v ~/.cuspd:/root/.cuspd -v ~/.cuspcli:/root/.cuspcli cusp cuspd start
FROM golang:alpine AS build-env

# Set up dependencies
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python3

# Set working directory for the build
WORKDIR /go/src/github.com/libonomy/cusp

# Add source files
COPY . .

# Install minimum necessary dependencies, build cusp SDK, remove packages
RUN apk add --no-cache $PACKAGES && \
    make tools && \
    make install

# Final image
FROM alpine:edge

# Install ca-certificates
RUN apk add --update ca-certificates
WORKDIR /root

# Copy over binaries from the build-env
COPY --from=build-env /go/bin/cuspd /usr/bin/cuspd
COPY --from=build-env /go/bin/cuspcli /usr/bin/cuspcli

# Run cuspd by default, omit entrypoint to ease using container with cuspcli
CMD ["cuspd"]
