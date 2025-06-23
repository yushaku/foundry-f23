source .env

forge script script/Deploy.s.sol \
  --rpc-url $RPC_URL \
  --keystore keystore/my-key.json \
  --password $KEYSTORE_PASSWORD \
  --broadcast