# launch-dill-node

## Introduction
`launch-dill-node` is a collection of scripts for operating the dill node, specifically including launching a new node, adding validators to the launched node, stopping the node, starting the node, viewing the validator's public key, and exiting the validator from chain.

## Tutorial for users
### Requirements
The dill node can run on two different operating systems.
- Ubuntu LTS 20.04+ with x86-64 CPU("adx" instruction set extension required)
- MacOS with M1/M2 CPU

### Launch a new dill node
In a host with no dill node running before, follow below steps to launch a new one.

#### Step 1: Download and Run the Dill Node Script

Open your terminal and execute the following command to launch a new Dill node:

```bash
curl -sO https://raw.githubusercontent.com/DillLabs/launch-dill-node/main/dill.sh && chmod +x dill.sh && ./dill.sh
```

#### Step 2: Generating Validator Keys
1. **Choose a new or existing mnemonic**:

Next, you will be prompted to generate your validator keys. You can either create a new mnemonic or use an existing one.

```bash
********** Step 2: Generating Validator Keys **********

Validator Keys are generated from a mnemonic
Please choose an option for mnemonic source [1, From a new mnemonic, 2, Use existing mnemonic] [1]:
```

- Choose `1` to generate a new mnemonic (ensure you save this securely).
- Choose `2` if you already have a mnemonic and wish to use it.

2. **Choose the deposit token amount and enter withdrawal address**:

Next, you will be asked to select the deposit token amount for staking, and then to provide a withdrawal address.

```bash
Please choose an option for deposit token amount [1, 3600, 2, 36000] [1]: 1
Please enter your withdrawal address: 0xaaaaaa(replaced by yours)

**[Warning] you are setting an Eth1 address as your withdrawal address. Please ensure that you have control over this address.**

Repeat your withdrawal address for confirmation.: 0xaaaaaa(replaced by yours)

**[Warning] you are setting an Eth1 address as your withdrawal address. Please ensure that you have control over this address.**
```

#### Step 3: Import keys and start dill-node
After launching successfully, you should see an output like this:

```
Checking if the node is up and running...
node running, congratulations 😄
```