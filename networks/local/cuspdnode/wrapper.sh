#!/usr/bin/env sh

##
## Input parameters
##
BINARY=/cuspd/${BINARY:-cuspd}
ID=${ID:-0}
LOG=${LOG:-cuspd.log}

##
## Assert linux binary
##
if ! [ -f "${BINARY}" ]; then
	echo "The binary $(basename "${BINARY}") cannot be found. Please add the binary to the shared folder. Please use the BINARY environment variable if the name of the binary is not 'cuspd' E.g.: -e BINARY=cuspd_my_test_version"
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
export CUSPDHOME="/cuspd/node${ID}/cuspd"

if [ -d "`dirname ${CUSPDHOME}/${LOG}`" ]; then
  "$BINARY" --home "$CUSPDHOME" "$@" | tee "${CUSPDHOME}/${LOG}"
else
  "$BINARY" --home "$CUSPDHOME" "$@"
fi

chmod 777 -R /cuspd

