# Simple usage with a mounted data directory:
# > docker build -t cusp .
# > docker run -it -p 46657:46657 -p 46656:46656 -v ~/.libod:/root/.libod -v ~/.libocli:/root/.libocli cusp libod init
# > docker run -it -p 46657:46657 -p 46656:46656 -v ~/.libod:/root/.libod -v ~/.libocli:/root/.libocli cusp libod start
FROM golang:alpine AS build-env

# Set up dependencies
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python3

# Set working directory for the build
WORKDIR /go/src/github.com/evdatsion/cusp

# Add source files
COPY . .

# Install minimum necessary dependencies, build Cosmos SDK, remove packages
RUN apk add --no-cache $PACKAGES && \
    make tools && \
    make install

# Final image
FROM alpine:edge

# Install ca-certificates
RUN apk add --update ca-certificates
WORKDIR /root

# Copy over binaries from the build-env
COPY --from=build-env /go/bin/libod /usr/bin/libod
COPY --from=build-env /go/bin/libocli /usr/bin/libocli

# Run libod by default, omit entrypoint to ease using container with libocli
CMD ["libod"]
