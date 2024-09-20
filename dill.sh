#!/bin/bash

_ROOT="$(pwd)" && cd "$(dirname "$0")" && ROOT="$(pwd)"
PJROOT="$ROOT"
DILL_DIR="$PJROOT/dill"

download=1
if [ $# -ge 1 ];then
    download=$1
fi

version="v1.0.3"
function launch_dill() {
    
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
            if [ "$download" != "0" ];then
                curl -O $DILL_DARWIN_ARM64_URL
                tar -zxvf $dill_darwin_file
            fi
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
                    if [ "$download" != "0" ];then
                        curl -O $DILL_LINUX_AMD64_URL
                        tar -zxvf $dill_linux_file
                    fi
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
    
    $DILL_DIR/1_launch_dill_node.sh
}

function add_validator() {
    $DILL_DIR/2_add_validator.sh
}

launch_dill
