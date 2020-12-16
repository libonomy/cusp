#!/usr/bin/env sh

##
## Input parameters
##
BINARY=/libod/${BINARY:-libod}
ID=${ID:-0}
LOG=${LOG:-libod.log}

##
## Assert linux binary
##
if ! [ -f "${BINARY}" ]; then
	echo "The binary $(basename "${BINARY}") cannot be found. Please add the binary to the shared folder. Please use the BINARY environment variable if the name of the binary is not 'libod' E.g.: -e BINARY=libod_my_test_version"
	exit 1
fi
BINARY_CHECK="$(file "$BINARY" | grep 'ELF 64-bit LSB executable, x86-64')"
if [ -z "${BINARY_CHECK}" ]; then
	echo "Binary needs to be OS linux, ARCH amd64"
	exit 1
fi

##
## Run binary with all parameters
##
export LIBODHOME="/libod/node${ID}/libod"

if [ -d "`dirname ${LIBODHOME}/${LOG}`" ]; then
  "$BINARY" --home "$LIBODHOME" "$@" | tee "${LIBODHOME}/${LOG}"
else
  "$BINARY" --home "$LIBODHOME" "$@"
fi

chmod 777 -R /libod

