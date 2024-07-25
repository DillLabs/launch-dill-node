#!/bin/bash

_ROOT="$(pwd)" && cd "$(dirname "$0")" && ROOT="$(pwd)"
PJROOT="$ROOT"

tlog() {
    echo "$(date '+%Y-%m-%d %H:%M:%S %Z') > $*"
}

# Ask for OS type
os_type=$(uname)
chip=$(uname -m)

DILL_DARWIN_ARM64_URL="https://dill-release.s3.ap-southeast-1.amazonaws.com/v1.0.0/dill-v1.0.0-darwin-arm64.tar.gz"
DILL_LINUX_AMD64_URL="https://dill-release.s3.ap-southeast-1.amazonaws.com/v1.0.0/dill-v1.0.0-linux-amd64.tar.gz"

if [ "$os_type" == "Darwin" ];then
    if [ "$chip" == "arm64" ];then
        tlog "supported, os_type: $os_type, chip: $chip"
        curl -O $DILL_DARWIN_ARM64_URL
        tar -zxvf dill-v1.0.0-darwin-arm64.tar.gz
    else
        tlog "Unsupported, os_type: $os_type, chip: $chip"
        exit 1
    fi
else
    if [ "$chip" == "x86_64" ] && [ -f /etc/os-release ];then
        source /etc/os-release
        if [ "$ID" == "ubuntu" ] && [ "$VERSION_ID" == "22.04" ];then
            tlog "supported, os_type: $os_type, chip: $chip, $ID $VERSION_ID"
            curl -O $DILL_LINUX_AMD64_URL
            tar -zxvf dill-v1.0.0-linux-amd64.tar.gz
        else
            tlog "Unsupported, os_type: $os_type, chip: $chip, $ID $VERSION_ID"
            exit 1
        fi
    else
        tlog "Unsupported, os_type: $os_type, chip: $chip"
        exit 1
    fi
fi

DILL_DIR="$PJROOT/dill"

dill_proc=$(ps axu | grep -v grep | grep dill-node | grep andes | grep light)
if [ ! -z "$dill_proc" ];then
    echo "It seems that there is already a dill light node running."
    echo "Only one dill node allowed in one machine."
    echo "If you want to launch a new one, you need to stop the currently running dill node."
    echo ""
    echo $dill_proc
    exit 1
fi

# Define variables
KEYS_DIR="$DILL_DIR/validator_keys"
KEYSTORE_DIR="$DILL_DIR/keystore"
PASSWORD_FILE="$KEYS_DIR/keystore_password.txt"

cd $DILL_DIR
# Generate validator keys
tlog "Generating validator keys..."
./dill_validators_gen new-mnemonic --num_validators=1 --chain=andes --deposit_amount 2500 --save_password --save_mnemonic

# Import your keys to your keystore
tlog "Importing keys to keystore..."
./dill-node accounts import --andes --wallet-dir $KEYSTORE_DIR --keys-dir $KEYS_DIR --accept-terms-of-use --account-password-file $PASSWORD_FILE --wallet-password-file $PASSWORD_FILE

# Start the light validator node
tlog "Starting light validator node..."
./start_light.sh

sleep 3
# Check if the node is up and running
tlog "Checking if the node is up and running..."
dill_proc=`ps -ef | grep dill | grep light | grep -v grep | grep 0x1a5E568E5b26A95526f469E8d9AC6d1C30432B33`
if [ ! -z "$dill_proc" ]; then
    tlog "node running, congratulations 😄"
else 
    tlog "node not running, something went wrong 😢"
    exit 1
fi

deposit_file=$(ls -t $DILL_DIR/validator_keys/deposit_data-* | head -n 1)
pubkeys=($(grep -o '"pubkey": "[^"]*' $deposit_file | sed 's/"pubkey": "//')) 
echo -e "the validator pubkey is \033[0;31m$pubkeys\033[0m"

echo -e "\033[0;31mPlease backup this directory $DILL_DIR/validator_keys, if you want to restore it on another machine\033[0m"