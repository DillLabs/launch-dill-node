#!/bin/bash

_ROOT="$(pwd)" && cd "$(dirname "$0")" && ROOT="$(pwd)"
PJROOT="$ROOT"

tlog() {
    echo "$(date '+%Y-%m-%d %H:%M:%S %Z') > $*"
}

# Ask for OS type
os_type=$(uname)
chip=$(uname -m)

DILL_DARWIN_ARM64_URL="https://dill-release.s3.ap-southeast-1.amazonaws.com/v1.0.1/dill-v1.0.1-darwin-arm64.tar.gz"
DILL_LINUX_AMD64_URL="https://dill-release.s3.ap-southeast-1.amazonaws.com/v1.0.1/dill-v1.0.1-linux-amd64.tar.gz"

if [ "$os_type" == "Darwin" ];then
    if [ "$chip" == "arm64" ];then
        tlog "supported, os_type: $os_type, chip: $chip"
        curl -O $DILL_DARWIN_ARM64_URL
        tar -zxvf dill-v1.0.1-darwin-arm64.tar.gz
    else
        tlog "Unsupported, os_type: $os_type, chip: $chip"
        exit 1
    fi
else
    if [ "$chip" == "x86_64" ] && [ -f /etc/os-release ];then
        if ! grep -qi "flags.*:.*adx" /proc/cpuinfo; then
            tlog "Unsupported CPU: Missing the required instruction set extension (adx)"
            exit 1
        fi
        source /etc/os-release
        if [ "$ID" == "ubuntu" ];then
            major_version=$(echo $VERSION_ID | cut -d. -f1)
            if [ $major_version -ge 20 ]; then
                tlog "supported, os_type: $os_type, chip: $chip, $ID $VERSION_ID"
                curl -O $DILL_LINUX_AMD64_URL
                tar -zxvf dill-v1.0.1-linux-amd64.tar.gz
            else
                tlog "Unsupported Ubuntu version: $VERSION_ID"
                exit 1
            fi
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

# check env variables LC_ALL and LANG
locale_a_value=$(locale -a)
locale_a_lower_value=$(echo $locale_a_value | tr '[:upper:]' '[:lower:]')

lc_all_value=$(echo "$LC_ALL")
lc_all_lower_value=$(echo "$LC_ALL" | tr '[:upper:]' '[:lower:]' | sed 's/-//g')
if ! echo $locale_a_lower_value | grep -q "\<$lc_all_lower_value\>"; then
    if echo $locale_a_lower_value | grep -q "c.utf8"; then
        export LC_ALL=C.UTF-8
        echo "LC_ALL value $lc_all_value not found in locale -a ($locale_a_value), and set to C.UTF-8 now"
    else
        echo "LC_ALL value $lc_all_value not found in locale -a ($locale_a_value), and can't set to C.UTF-8!!!"
    fi
fi

lang_value=$(echo "$LANG")
lang_lower_value=$(echo "$LANG" | tr '[:upper:]' '[:lower:]' | sed 's/-//g')
if ! echo $locale_a_lower_value | grep -q "\<$lang_lower_value\>"; then
    if echo $locale_a_lower_value | grep -q "c.utf8"; then
        export LANG=C.UTF-8
        echo "LANG value $lang_value not found in locale -a ($locale_a_value), and set to C.UTF-8 now"
    else
        echo "LANG value $lang_value not found in locale -a ($locale_a_value), and can't set to C.UTF-8"
    fi
fi

cd $DILL_DIR
# Generate mnemonic
tlog "Generating mnemonic"
mnemonic_path="$DILL_DIR/validator_keys/mnemonic.txt"
# Check if the file exists and has content
if [ -s "$mnemonic_path" ]; then
    echo "File $mnemonic_path exists and has content. Please move the file if the content is important, as it will be overwritten."
    while true; do
        read -p "Do you want to overwrite the file? (yes/no): " response
        case "$response" in
            "yes" | "YES")
                break
                ;;
            "no" | "NO")
                echo "Please move the $mnemonic_path file, and rerun the script"
                exit 1
                ;;
            *)
                echo "Invalid response. Please enter 'yes' or 'no'."
                ;;
        esac
    done
fi

mnemonic=""
save_mnemonic=""
read -p "Do you want to generate a new mnemonic? (Press Enter for new / type 'no' to use existing): " generate_new
while true; do
    case "$generate_new" in
        "" | "yes")
            ./dill_validators_gen generate-mnemonic --mnemonic_path $mnemonic_path
            ret=$?
            if [ $ret -ne 0 ]; then
                echo "dill_validators_gen generate-mnemonic failed"
                exit 1
            fi
            save_mnemonic="yes"
            mnemonic="$(cat $mnemonic_path)"
            break
            ;;
        "no")
            read -p "Enter the existing mnemonic: " existing_mnemonic
            mnemonic="$existing_mnemonic"
            break
            ;;
        *)
            echo "Invalid response. Please press Enter for new or type 'no' for existing."
            read -p "Do you want to generate a new mnemonic? (Press Enter for new / type 'no' to use existing): " generate_new
            ;;
    esac
done

# wait enter password
password=""
echo ""
while true; do
    read -s -p "Create a password that secures your validator keystore(s). (minimum 8 characters): " password
    if [ ${#password} -ge 8 ]; then
        break
    else
        echo "Password must be at least 8 characters long."
    fi
done
[ ! -d "$KEYS_DIR" ] && mkdir -p "$KEYS_DIR"
echo $password > $PASSWORD_FILE

# Generate validator keys
echo ""; tlog "Generating validator keys..."
./dill_validators_gen existing-mnemonic --mnemonic="$mnemonic" --validator_start_index=0 --num_validators=1 --chain=andes --deposit_amount=2500 --keystore_password="$password"
ret=$?
if [ $ret -ne 0 ]; then
    echo "dill_validators_gen existing-mnemonic failed"
    exit 1
fi

# Import your keys to your keystore
tlog "Importing keys to keystore..."
./dill-node accounts import --andes --wallet-dir $KEYSTORE_DIR --keys-dir $KEYS_DIR --accept-terms-of-use --account-password-file $PASSWORD_FILE --wallet-password-file $PASSWORD_FILE

# Start the light validator node
tlog "Starting light validator node..."
./start_light.sh

sleep 3
# Check if the node is up and running
tlog "Checking if the node is up and running..."
dill_proc=`ps -ef | grep dill | grep light`
if [ ! -z "$dill_proc" ]; then
    echo "node running, congratulations 😄"
else 
    echo "node not running, something went wrong!!! 😢"
    exit 1
fi

deposit_file=$(ls -t $DILL_DIR/validator_keys/deposit_data-* | head -n 1)
pubkeys=($(grep -o '"pubkey": "[^"]*' $deposit_file | sed 's/"pubkey": "//')) 
echo -e "\033[0;36mvalidator pubkey\033[0m: $pubkeys"

if [ "$save_mnemonic" == "yes" ]; then
    echo -e "\033[0;31mPlease backup $mnemonic_path. Required for recovery and migration. Important ！！！\033[0m"
fi
