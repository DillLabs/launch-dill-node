# launch-dill-node <!-- omit from toc -->

## Table of Contents <!-- omit from toc -->
- [1. Introduction](#1-introduction)
- [2. Tutorial for users](#2-tutorial-for-users)
  - [2.1 Launch a new dill node](#21-launch-a-new-dill-node)
    - [2.1.1 Download and Run the Dill Node Script](#211-download-and-run-the-dill-node-script)
    - [2.1.2 Start dill node](#212-start-dill-node)
    - [2.1.3 Generating Validator Key and deposit file](#213-generating-validator-key-and-deposit-file)
      - [Add a solo validator to your node](#add-a-solo-validator-to-your-node)
      - [Add a pool validator to your node](#add-a-pool-validator-to-your-node)
      - [Recover a validator to your node](#recover-a-validator-to-your-node)
  - [2.2 Add a solo staking validator to existing node](#22-add-a-solo-staking-validator-to-existing-node)
  - [2.3 Add a pool staking validator to existing node](#23-add-a-pool-staking-validator-to-existing-node)
  - [2.4 Recover a validator to existing node](#24-recover-a-validator-to-existing-node)
  - [2.5 Other useful commands](#25-other-useful-commands)

# 1. Introduction
`launch-dill-node` is a collection of scripts for operating the dill node, specifically including launching a new node, adding validators to the launched node, stopping the node, starting the node, viewing the validator's public key, and exiting the validator from chain.

# 2. Tutorial for users

## 2.1 Launch a new dill node
In a host with no dill node running before, follow below steps to launch a new one.

### 2.1.1 Download and Run the Dill Node Script

Open your terminal and execute the following command to launch a new Dill node:

```bash
curl -sO https://raw.githubusercontent.com/DillLabs/launch-dill-node/main/dill.sh && chmod +x dill.sh && ./dill.sh
```
### 2.1.2 Start dill node

You need to choose a node type

```bash
Please select the node type to proceed [1. light, 2. full]: 
```
- Choose `1` to run a light node.
- Choose `2` to run a full node.

Please note that for pool validator you need to run a full node.

After launching successfully, you should see an output like this:

```
Checking if the node is up and running...
node running, congratulations 😄
```

### 2.1.3 Generating Validator Key and deposit file

```bash
Please select the validator operation [1. add a solo validator, 2. add a pool validator, 3. recover a validator]:
```
- Choose `1` to add a solo validator to your node.
- Choose `2` to add a pool validator to your node.
- Choose `3` to recover a validator from mnemonic and add it to your node.

#### Add a solo validator to your node

You will be prompted to generate your validator key. You can either create a new mnemonic or use an existing one.
```bash
Validator Keys are generated from a mnemonic
Please choose an option for mnemonic source [1, From a new mnemonic, 2, Use existing mnemonic] [1]: 
```

- Choose `1` to generate a new mnemonic (ensure you save this securely).
- Choose `2` if you already have a mnemonic and would like to use it.

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

#### Add a pool validator to your node

You will be prompted to generate your validator keys. You can either create a new mnemonic or use an existing one.
```bash
Validator Keys are generated from a mnemonic
Please choose an option for mnemonic source [1, From a new mnemonic, 2, Use existing mnemonic] [1]: 
```

- Choose `1` to generate a new mnemonic (ensure you save this securely).
- Choose `2` if you already have a mnemonic and would like to use it.

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

#### Recover a validator to your node

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

## 2.2 Add a solo staking validator to existing node

- Full node: you can run multiple full validators.
- Light node: you can run multiple light validators on it.

Execute the following command to add a validator on the full or light node.

```bash
 <YOUR_FOLDER_PATH>/dill/2_add_validator.sh
```

Then please refer to [Add a solo validator to your node](#Add-a-solo-validator-to-your-node).

## 2.3 Add a pool staking validator to existing node

***Pool validators can only be added to a full node.***

Execute the following command to add a validator on the full or light node.

```bash
 <YOUR_FOLDER_PATH>/dill/3_add_pool_validator.sh
```

Then please refer to [Add a pool validator to your node](#Add-a-pool-validator-to-your-node).

## 2.4 Recover a validator to existing node

Execute the following command to recover your validator key.

```bash
 <YOUR_FOLDER_PATH>/dill/4_recover_validator.sh
```

Then please refer to [Recover a validator to your node](#Recover-a-validator-to-existing-node).

## 2.5 Other useful commands
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

- Upgrade node type
Use this script to upgrade your light node to full node.
```bash
./light_to_full.sh
```
