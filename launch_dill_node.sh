#!/bin/bash

_ROOT="$(pwd)" && cd "$(dirname "$0")" && ROOT="$(pwd)"
PJROOT="$ROOT"

# Ask for OS type
os_type=$(uname)   # Darwin or Linux
chip=$(uname -m)

version="v1.0.2"
dill_darwin_file="dill-$version-darwin-arm64.tar.gz"
dill_linux_file="dill-$version-linux-amd64.tar.gz"
DILL_DARWIN_ARM64_URL="https://dill-release.s3.ap-southeast-1.amazonaws.com/$version/$dill_darwin_file"
DILL_LINUX_AMD64_URL="https://dill-release.s3.ap-southeast-1.amazonaws.com/$version/$dill_linux_file"

echo ""
echo "********** Step 1: Checking hardware/OS and downloading dill software package **********"
echo ""

if [ "$os_type" == "Darwin" ];then
    if [ "$chip" == "arm64" ];then
        echo "Supported, os_type: $os_type, chip: $chip"
        curl -O $DILL_DARWIN_ARM64_URL
        tar -zxvf $dill_darwin_file
    else
        echo "Unsupported, os_type: $os_type, chip: $chip"
        exit 1
    fi
else
    if [ "$chip" == "x86_64" ] && [ -f /etc/os-release ];then
        source /etc/os-release
        if [ "$ID" == "ubuntu" ];then
            major_version=$(echo $VERSION_ID | cut -d. -f1)
            if [ $major_version -ge 20 ]; then
                echo "Supported, os: $ID $VERSION_ID, chip: $chip"; echo""
                curl -O $DILL_LINUX_AMD64_URL
                tar -zxvf $dill_linux_file
            else
                echo "Unsupported, os: $ID $VERSION_ID (ubuntu 20.04+ required)"
                exit 1
            fi
        else
            echo "Unsupported, os_type: $os_type, chip: $chip, $ID $VERSION_ID"
            exit 1
        fi
    else
        echo "Unsupported, os_type: $os_type, chip: $chip"
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

if [ "$os_type" == "Linux" ];then
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
fi

echo ""
echo "Step 1 Completed. Press any key to continue..."
read -n 1 -s -r
echo ""  # Move to a new line after the key press

echo ""
echo "********** Step 2: Generating Validator Keys **********"
echo ""

echo "Validator Keys are generated from a mnemonic"
mnemonic=""
save_mnemonic=""
timestamp=$(date +%s)
mnemonic_path="$DILL_DIR/validator_keys/mnemonic-$timestamp.txt"
cd $DILL_DIR
while true; do
    read -p "Please choose an option for mnemonic source [1, From a new mnemonic, 2, Use existing mnemonic] [1]: " mne_src
    mne_src=${mne_src:-1}  # Set default choice to 1
    case "$mne_src" in
        "1" | "new")
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
        "2" | "existing")
            read -p "Enter your existing mnemonic: " existing_mnemonic
            if [[ $existing_mnemonic =~ ^([a-zA-Z]+[[:space:]]+){11,}[a-zA-Z]+$ ]]; then
                mnemonic="$existing_mnemonic"
                break
            else
                echo ""
                echo "[Error]Invalid mnemonic format. A valid mnemonic should consist of 12 or more space-separated words."
            fi
            ;;
        *)
            echo ""
            echo "[Error] $mne_src is not a valid mnemonic source option"
            ;;
    esac
done

# wait enter password
password=""
echo ""
echo "Generate a random password that secures your validator keystore(s)."
password=$(openssl rand -base64 12)  # Generate a random password
echo ""
echo "Generated password: $password"
echo ""
echo "The password will be saved to $PASSWORD_FILE. Press any key to continue..."
read -n 1 -s -r
echo ""  # Move to a new line after the key press
[ ! -d "$KEYS_DIR" ] && mkdir -p "$KEYS_DIR"
echo $password > $PASSWORD_FILE

# Generate validator keys
./dill_validators_gen existing-mnemonic --mnemonic="$mnemonic" --validator_start_index=0 --num_validators=1 --chain=andes --deposit_amount=2500 --keystore_password="$password"
ret=$?
if [ $ret -ne 0 ]; then
    echo "dill_validators_gen existing-mnemonic failed"
    exit 1
fi
echo ""
echo "Step 2 Completed. Press any key to continue..."
read -n 1 -s -r
echo ""  # Move to a new line after the key press

echo ""
echo "********** Step 3: Import keys and start dill-node **********"
echo ""

# Import your keys to your keystore
echo "Importing keys to keystore..."
./dill-node accounts import --andes --wallet-dir $KEYSTORE_DIR --keys-dir $KEYS_DIR --accept-terms-of-use --account-password-file $PASSWORD_FILE --wallet-password-file $PASSWORD_FILE
ret=$?
if [ $ret -eq 132 ]; then
    # Check if dill-node is a symbolic link
    if [ -L "dill-node" ]; then
	old_target=$(readlink -f "dill-node")
	old_target_name=$(basename "$old_target")
        echo "Old symbolic link dill-node linked to $old_target_name deleted"
        rm -f dill-node

        ln -s ./dill-node_blst_portable dill-node
	ret=$?
	if [ $ret -ne 0 ]; then
	    echo "Create symbolic link dill-node failed"
	else
            echo "New symbolic link dill-node created, linked to ./dill-node_blst_portable."
            ./dill-node accounts import --andes --wallet-dir $KEYSTORE_DIR --keys-dir $KEYS_DIR --accept-terms-of-use --account-password-file $PASSWORD_FILE --wallet-password-file $PASSWORD_FILE
	fi
    fi
fi

# Start the light validator node
echo "Starting light validator node..."
./start_light.sh

sleep 3
# Check if the node is up and running
echo "Checking if the node is up and running..."
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

echo ""
echo "Step 3 Completed. The whole process finished. Press any key..."
read -n 1 -s -r
echo ""  # Move to a new line after the key press
