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

Next, you will be asked to select the deposit token amount for staking, 

```bash
Please choose an option for deposit token amount [1, 3600, 2, 36000] [1]:
```
   - Option `1`: 3600 DILL (run a light node with a light validator)
   - Option `2`: 36000 DILL (run a full node with a full validator)

then need to provide a withdrawal address.

```bash
Please enter your withdrawal address: <YOUR_WITHDRAWAL_ADDRESS>

**[Warning] you are setting an Eth1 address as your withdrawal address. Please ensure that you have control over this address.**

Repeat your withdrawal address for confirmation.: <YOUR_WITHDRAWAL_ADDRESS>

**[Warning] you are setting an Eth1 address as your withdrawal address. Please ensure that you have control over this address.**
```

You will see the following messages after successfully generated the keystore(s) and the deposit(s):

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

#### Step 3: Import keys and start dill-node
After launching successfully, you should see an output like this:

```
Checking if the node is up and running...
node running, congratulations 😄
```

A node with a validator is running now, but to become a validator on the Alps chain, you still need to perform staking. Please refer to the link https://dill.xyz/docs/RunANode/Alps#staking for details.

### Add a validator to existing node

- Full node (a full validator is already running by default):you can run multiple full validators or multiple light validators on it.
- Light node (a light validator is already running by default):you can run multiple light validators on it.

Execute the following command to add a validator on the full or light node.

```bash
 <YOUR_FOLDER_PATH>/dill/2_add_validator.sh
```

#### Step 1: Generating Validator Keys

1. **Choose a new or existing mnemonic**:

```bash
********** Step 1: Generating Validator Keys **********

Validator Keys are generated from a mnemonic
Please choose an option for mnemonic source [1, From a new mnemonic, 2, Use existing mnemonic] [1]:
```

- Choose `1` to generate a new mnemonic (ensure you save this securely).
- Choose `2` if you already have a mnemonic and wish to use it.

Choosing option 1 is analogous to the process described in 'Launch a new dill node'; But if option 2 is chosen, the index (key number) needs to be entered later.

2. **Choose the deposit token amount and enter withdrawal address**:

```bash
Please choose an option for deposit token amount [1, 3600, 2, 36000] [1]:
```
   - Option `1`: 3600 DILL (add a light validator)
   - Option `2`: 36000 DILL (add a full validator)

then need to provide a withdrawal address.
```bash
Please enter your withdrawal address: <YOUR_WITHDRAWAL_ADDRESS>

**[Warning] you are setting an Eth1 address as your withdrawal address. Please ensure that you have control over this address.**

Repeat your withdrawal address for confirmation.: <YOUR_WITHDRAWAL_ADDRESS>

**[Warning] you are setting an Eth1 address as your withdrawal address. Please ensure that you have control over this address.**
```

If 'Use existing mnemonic' was chosen earlier, there will be the following input options.

3. **Enter the index (key number) you wish to start generating more keys from**:

```bash
Enter the index (key number) you wish to start generating more keys from. For example, if you've generated 4 keys in the past, you'd enter 4 here. [0]: <YOUR_INDEX>
```

If no additional validators have been added before, you need to enter 1 here, as a validator has been generated before in "Launch a new dill node" by default.

If n additional validators have been added in "Add a validator to existing node", then enter n+1 here. 

Then the keystore(s) and the deposit(s) will be generated.

Please remember to save the mnemonic and index, as both are necessary to generate the correct validator key, which is needed to recover or migrate the dill node.

#### Step 2: Import keys

After importing keys successfully, you should see an output like this:

```bash
INFO accounts: Imported accounts [<YOUT_PUBLIC_KEY>], view all of them by running `accounts list`
```

Then the dill node will automatically detect the newly imported validator keys and run the validator.

Next, you still need to stake with the newly generated ./validator_keys/deposit_data-xxxx.json file. Please refer to the link https://dill.xyz/docs/RunANode/Alps#staking for details.