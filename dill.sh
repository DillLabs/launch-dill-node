#!/bin/bash

_ROOT="$(pwd)" && cd "$(dirname "$0")" && ROOT="$(pwd)"
PJROOT="$ROOT"
DILL_DIR="$PJROOT/dill"

if [ $# -ge 1 ];then
    skip_down_load=$1
fi

latest_release_url="https://dill-release.s3.ap-southeast-1.amazonaws.com/version.txt"
version=`curl -s $latest_release_url`
if [ -z "$version" ]; then
    echo "Cannot get latest version"
    exit 1
fi

function print_step() {
        local step=$1
        local msg=$2
        echo ""
        echo "********** Step $step: $msg **********"
        echo ""
}

function print_step_complete() {
        local step=$1
	step_phrase="Step $step"
	if [ -z "$step" ]; then
		step_phrase="All steps"
	fi
        echo ""
        echo "$step_phrase Completed. Press any key to continue..."
        read -n 1 -s -r
        echo ""  # Move to a new line after the key press
}

function download() {
    # Ask for OS type
    os_type=$(uname)   # Darwin or Linux
    chip=$(uname -m)

    dill_darwin_file="dill-$version-darwin-arm64.tar.gz"
    dill_linux_file="dill-$version-linux-amd64.tar.gz"
    DILL_DARWIN_ARM64_URL="https://dill-release.s3.ap-southeast-1.amazonaws.com/$version/$dill_darwin_file"
    DILL_LINUX_AMD64_URL="https://dill-release.s3.ap-southeast-1.amazonaws.com/$version/$dill_linux_file"

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
            if ! grep -qi "flags.*:.*adx" /proc/cpuinfo; then
                echo "Warn: The cpu lacks the required instruction set extension (adx) and may not run properly."
                echo "But you can also try. Press any key to continue..."
                read -n 1 -s -r
            fi

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
}

if ! [ "$skip_down_load" == "1" ]; then
	download
	echo ""
fi

print_step 1 "Run dill node"

while true; do
	read -p "Please select the node type to proceed [1. light, 2. full]: " node_type
	case "$node_type" in
                "1" | "light")
                        node_type="light"
                        break
                        ;;
                "2" | "full")
                        node_type="full"
                        break
                        ;;
                *)
                        echo ""
                        echo "[Error] $node_type is not a valid node type option"
                        ;;
        esac
done
echo ""

cd $DILL_DIR
./1_launch_dill_node.sh $node_type
if [ $? -ne 0 ]; then
	exit $?
fi
print_step_complete 1
print_step 2 "Generate validator key and deposit file"


if [ "$node_type" == "light" ]; then
	stake_type="1"
	while true; do
	        read -p "Please select the validator operation [1. add a solo validator, 2. recover a validator]: " op
	        case "$op" in
	                "1")
	                        intent_type="run"
	                        break
	                        ;;
	                "2")
	                        intent_type="recover"
	                        break
	                        ;;
	                *)
	                        echo ""
	                        echo "[Error] $op is not a valid option"
	                        ;;
	        esac
	done
else
	while true; do
	        read -p "Please select the validator operation [1. add a solo validator, 2. add a pool validator, 3. recover a validator]: " op
	        case "$op" in
	                "1")
	                        stake_type=1
	                        intent_type="run"
	                        break
	                        ;;
	                "2")
	                        stake_type=2
	                        intent_type="run"
	                        break
	                        ;;
	                "3")
	                        intent_type="recover"
	                        break
	                        ;;
	                *)
	                        echo ""
	                        echo "[Error] $stake_type is not a valid staking type option"
	                        ;;
	        esac
	done
fi
echo ""

if [ "$intent_type" == "recover" ]; then
        ./4_recover_validator.sh
        if [ $? -ne 0 ]; then
                exit $?
        fi
        print_step_complete
        exit 0
fi

if [ "$stake_type" == "1" ]; then
	./2_add_validator.sh
else
	./3_add_pool_validator.sh
fi
if [ $? -ne 0 ]; then
        exit $?
fi
print_step_complete
exit 0