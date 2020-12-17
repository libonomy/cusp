#!/usr/bin/env bash

PASSWORD="1234567890"
ADDR="libonomy16xyempempp92x9hyzz9wrgf94r6j9h5f06pxxv"
RECEIVER="libonomy17gx5vwpm0y2k59tw0x00ccug234n56cgltx2w2"
VALIDATOR="libonomyvaloper16xyempempp92x9hyzz9wrgf94r6j9h5f2w4n2l"
AMOUNT="1000000libocoin"
CHAIN="lcd"
PROPOSALID="2"
HOME="/tmp/contract_tests/.cuspcli"
SWAGGER='/tmp/contract_tests/swagger.yaml'

# sleeping a whole second between each step is a conservative precaution
# check lcd_test/testdata/state.tar.gz -> .cuspd/config/config.toml precommit_timeout = 500ms
sleep 1s
echo ${PASSWORD} | ./build/cuspcli tx gov submit-proposal --home ${HOME} --from ${ADDR} --chain-id ${CHAIN} --type text --title test --description test_description --deposit 10000libocoin --yes
sleep 1s
echo ${PASSWORD} | ./build/cuspcli tx gov deposit --home ${HOME} --from ${ADDR} --chain-id ${CHAIN} ${PROPOSALID} 1000000000libocoin --yes
sleep 1s
echo ${PASSWORD} | ./build/cuspcli tx gov vote --home ${HOME} --from ${ADDR} --yes --chain-id ${CHAIN} ${PROPOSALID} Yes
sleep 1s
HASH=$(echo ${PASSWORD} | ./build/cuspcli tx send --home ${HOME} ${ADDR} ${RECEIVER} ${AMOUNT} --yes --chain-id ${CHAIN} | awk '/txhash.*/{print $2}')
sed -i.bak -e "s/BCBE20E8D46758B96AE5883B792858296AC06E51435490FBDCAE25A72B3CC76B/${HASH}/g" "${SWAGGER}"
echo "Replaced dummy with actual transaction hash ${HASH}"
sleep 1s
echo ${PASSWORD} | ./build/cuspcli tx staking unbond --home ${HOME} --from ${ADDR} ${VALIDATOR} 100libocoin --yes --chain-id ${CHAIN}

