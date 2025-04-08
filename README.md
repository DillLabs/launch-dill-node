# launch-dill-node

## Table of Contents
- [launch-dill-node](#launch-dill-node)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Tutorial for users](#tutorial-for-users)
    - [Requirements](#requirements)
    - [Launch a new dill node](#launch-a-new-dill-node)
      - [Step 1: Download and Run the Dill Node Script](#step-1-download-and-run-the-dill-node-script)
      - [Step 2: Start dill node](#step-2-start-dill-node)
      - [Step 3: Generating Validator Key and deposit file](#step-3-generating-validator-key-and-deposit-file)
        - [Add a solo validator to your node](#add-a-solo-validator-to-your-node)
        - [Add a pool validator to your node](#add-a-pool-validator-to-your-node)
        - [Recover a validator from mnemonic and add it to your node](#recover-a-validator-from-mnemonic-and-add-it-to-your-node)
    - [Add a solo staking validator to existing node](#add-a-solo-staking-validator-to-existing-node)
    - [Add a pool staking validator to existing node](#add-a-pool-staking-validator-to-existing-node)
    - [Add a pool staking validator to existing node](#add-a-pool-staking-validator-to-existing-node-1)
    - [Recover a validator from mnemonic and add it to your node](#recover-a-validator-from-mnemonic-and-add-it-to-your-node-1)
    - [Some other useful commands](#some-other-useful-commands)
  - [Frequently Asked Questions](#frequently-asked-questions)
    - [What to save for node recovery?](#what-to-save-for-node-recovery)
    - [How to recover the dill node?](#how-to-recover-the-dill-node)

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
#### Step 2: Start dill node

You need to choose a node type

```bash
Please select the node type to proceed [1. light, 2. full]: 
```
- Choose `1` to run a light node.
- Choose `2` to run a full node.

Mind that, for pool validator you need to run a full node.

After launching successfully, you should see an output like this:

```
Checking if the node is up and running...
node running, congratulations 😄
```

#### Step 3: Generating Validator Key and deposit file

```bash
Please select the validator operation [1. add a solo validator, 2. add a pool validator, 3. recover a validator]:
```
- Choose `1` to add a solo validator to your node.
- Choose `2` to add a pool validator to your node.
- Choose `3` to recover a validator from mnemonic and add it to your node.

##### Add a solo validator to your node

You will be prompted to generate your validator key. You can either create a new mnemonic or use an existing one.
```bash
Validator Keys are generated from a mnemonic
Please choose an option for mnemonic source [1, From a new mnemonic, 2, Use existing mnemonic] [1]: 
```

- Choose `1` to generate a new mnemonic (ensure you save this securely).
- Choose `2` if you already have a mnemonic and wish to use it.

A withdrawal address is required to complete the next setup

```bash
Please enter your withdrawal address:
```

And also a deposit amount. For full node it's like:
```bash 
Please enter a deposit amount from [3600, 7200, ...,  36000]:
```

and for light node:
```bash 
Please enter a deposit amount from [3600, 7200, ...,  32400]:
```

To achieve full validator status, a stake of 36,000 tokens is required. If the staked amount is below this threshold, the validator will operate as a light validator.
The staked amount must be a multiple of 3,600.

You will see the following messages after successfully generated the validator key and the deposit:

```bash
                       _______       __     __     __
                      |       \     (__)   |  |   |  |
                      |   ___  \     __    |  |   |  |
                      |  |   |  |   |  |   |  |   |  |
                      |  |   |  |   |  |   |  |   |  |
                      |  |   |  |   |  |   |  |   |  |
                      |  |___|  |   |  |   |  |   |  |
                      |        /    |  |   |  |   |  |
                      |_______/     |__|   |__|   |__|

Creating your keys.
Creating your keystores:	  [####################################]  1/1
Verifying your keystores:	  [####################################]  1/1
Verifying your deposits:	  [####################################]  1/1

Success!
Your keys can be found at: <YOUR_FOLDER_PATH>/dill/validator_keys
```

The generated file <YOUR_FOLDER_PATH>/dill/validator_keys/deposit_data-xxxx.json is required for staking later.


The system displays this confirmation message when the generated key has been successfully added to the node.

```bash
[2025-04-07 19:25:15]  INFO accounts: Imported accounts [YOUR_VALIDATOR_PUBLIC_KEY], view all of them by running `accounts list`
```

##### Add a pool validator to your node

You will be prompted to generate your validator keys. You can either create a new mnemonic or use an existing one.
```bash
Validator Keys are generated from a mnemonic
Please choose an option for mnemonic source [1, From a new mnemonic, 2, Use existing mnemonic] [1]: 
```

- Choose `1` to generate a new mnemonic (ensure you save this securely).
- Choose `2` if you already have a mnemonic and wish to use it.

A valid deposit wallet address must be provided. This designated address should be used as the originating account for the deposit transaction.

```bash
Please input your deposit wallet address:
```

The system will prompt for validator runtime duration specification. Upon reaching the specified duration threshold, the validator will automatically exit.

```bash
Please select validator running duration [1: 45 days, 2: 90 days] [1]:
```

- Choose `1` the pool validator will run for 45 days.
- Choose `2` the pool validator will run for 90 days.

You will see the following messages after successfully generated the validator key and the deposit:

```bash
                       _______       __     __     __
                      |       \     (__)   |  |   |  |
                      |   ___  \     __    |  |   |  |
                      |  |   |  |   |  |   |  |   |  |
                      |  |   |  |   |  |   |  |   |  |
                      |  |   |  |   |  |   |  |   |  |
                      |  |___|  |   |  |   |  |   |  |
                      |        /    |  |   |  |   |  |
                      |_______/     |__|   |__|   |__|

Creating your keys.
Creating your keystores:	  [####################################]  1/1
Verifying your keystores:	  [####################################]  1/1
Verifying your deposits:	  [####################################]  1/1

Success!
Your keys can be found at: <YOUR_FOLDER_PATH>/dill/validator_keys
```

And the last line of the output is a system-generated reminder indicating the location of the deposit file:

```bash 
Pool valildator deposit is written to <YOUR_FOLDER_PATH>/dill/validator_keys/deposit_pool_data-xxxx.json
```

##### Recover a validator from mnemonic and add it to your node

You will be prompted to enter your mnemonic. Normaly mnemonics can be found at "<YOUR_FOLDER_PATH>/dill/validator_keys":

```bash 
Enter your existing mnemonic:
```

The system will prompt for a validator index input:

```bash
Please enter a number as your validator public key index:
```

When unspecified, the system automatically assigns `0` as the default public key index value.

You will see the following messages after successfully generated the validator key:

```bash
                       _______       __     __     __
                      |       \     (__)   |  |   |  |
                      |   ___  \     __    |  |   |  |
                      |  |   |  |   |  |   |  |   |  |
                      |  |   |  |   |  |   |  |   |  |
                      |  |   |  |   |  |   |  |   |  |
                      |  |___|  |   |  |   |  |   |  |
                      |        /    |  |   |  |   |  |
                      |_______/     |__|   |__|   |__|

Creating your keys.
Creating your keystores:	  [####################################]  1/1
Verifying your keystores:	  [####################################]  1/1
Verifying your deposits:	  [####################################]  1/1

Success!
Your keys can be found at: <YOUR_FOLDER_PATH>/dill/validator_keys
```

The system displays this confirmation message when the generated key has been successfully added to the node.

```bash
[2025-04-07 19:25:15]  INFO accounts: Imported accounts [YOUR_VALIDATOR_PUBLIC_KEY], view all of them by running `accounts list`
```

### Add a solo staking validator to existing node

- Full node: you can run multiple full validators.
- Light node: you can run multiple light validators on it.

Execute the following command to add a validator on the full or light node.

```bash
 <YOUR_FOLDER_PATH>/dill/2_add_validator.sh
```

Then please refer to [Add a solo validator to your node](#Add-a-solo-validator-to-your-node).

### Add a pool staking validator to existing node

***Pool validators can only be added to a full node.***

Execute the following command to add a validator on the full or light node.

```bash
 <YOUR_FOLDER_PATH>/dill/3_add_pool_validator.sh
```

Then please refer to [Add a pool validator to your node](#Add-a-pool-validator-to-your-node).

### Add a pool staking validator to existing node

***Pool validators can only be added to a full node.***

Execute the following command to add a validator on the full or light node.

```bash
 <YOUR_FOLDER_PATH>/dill/3_add_pool_validator.sh
```

Then please refer to [Add a pool validator to your node](#Add-a-pool-validator-to-your-node).

### Recover a validator from mnemonic and add it to your node

Execute the following command to recover your validator key.

```bash
 <YOUR_FOLDER_PATH>/dill/4_recover_validator.sh
```

Then please refer to [Recover a validator from mnemonic and add it to your node](#Recover-a-validator-from-mnemonic-and-add-it-to-your-node).

### Some other useful commands
In the dill directory, there are also some useful scripts that will be used in daily operations.

- Check if the dill node is running healthily
```bash
./health_check.sh
```

- View the public key of the validators
```bash
./show_pubkey.sh
```

- Stop the dill node
```bash
./stop_dill_node.sh
```

- Start the dill node
```bash
./start_dill_node.sh
```

- Exit the validator(s)
Use the Exit script to signal your intentions to permanently stop your duties as a validator.
```bash
./exit_validator.sh
```

## Frequently Asked Questions
### What to save for node recovery?
In case of unexpected events like data loss or machine damage, the node must be recovered on the original or a new machine. For security, ensure you save the following items in advance:

- **Single Validator**: Save **the mnemonic** and **the deposit token amount**. **(Important: Losing these means losing access to your validator!)**
- **Multiple Validators**: Save **all mnemonics**, **the indices (key numbers) of validator keys**, and **the deposit token amounts**. **(Important: Ensure all details are backed up securely!)**

### How to recover the dill node?

Then whole recovery steps are as below: 
1. **Move the existing dill directory and terminate the process**:

```bash
[ -d dill ] && mv dill dill-$(date +%Y%m%d%H%M%S)
ps aux | grep -i dill | grep -v grep | awk '{print $2}' | xargs -r kill
```

2. **Launch a new dill node**

Rerun this script
```bash
curl -sO https://raw.githubusercontent.com/DillLabs/launch-dill-node/main/dill.sh && chmod +x dill.sh && ./dill.sh
```
```bash
Please select the validator operation [1. add a solo validator, 2. add a pool validator, 3. recover a validator]:
```

Choose `3`, recover a validator from mnemonic and add it to your node.

3. **Add validator(s) to the new node (if multiple validators existed)**

If multiple validators were running on the original dill node, in addition to the default validator when launching a new node, the remaining validators need to be added one by one to the new node.

Run the below script, and complete 
```bash
 <YOUR_FOLDER_PATH>/dill/4_recover_validator.sh
```