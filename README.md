# launch-dill-node

# Dill Public Testnet (Andes Testnet) Information
| Network Name     | Dill Testnet Andes |
| ------------- | ---------------- |
Rpc URL | https://rpc-andes.dill.xyz/
Chain ID | 558329
Currency Symbol | DILL
Explorer URL | https://andes.dill.xyz/

# Hardware Requirements
| Hardware | Requirement |
| ------------- | ---------------- |
Cpu | 2 Cores
Architecture | x86-64 (x64, x86_64, AMD64, ve Intel 64)
Memory | 2 GB
Operating System | Ubuntu 22.04.2+ / MacOS
Storage | 20 GB
Network Bandwidth | 1MB/s 

# Instructions

## Run a light validator
Light validator is a type of node that performs availability validation solely through data sampling without participating in data sharding synchronization. It is also part of a consensus network. These nodes can participate in voting but will not act as proposers to generate new blocks. You can follow the steps below to start a light validator:


1. **Download and run the setup script:**

Open your terminal and execute the following command to download and run the script:

   ```sh
   curl -O https://raw.githubusercontent.com/DillLabs/launch-dill-node/main/launch_dill_node.sh  && chmod +x launch_dill_node.sh && ./launch_dill_node.sh
   ```

2. **Do the following in order** 

- Wait for the files to download.
- Create a strong password. At least 8 characters long and confirm Keystore Password:
- Press enter to confirm after validator keys generated 

If you completed all the steps correctly, you will get an output similar to this:

```
node running, congratulations 😄
validator pubkey: xxxxxx
Please backup this directory /data/launch-dill-node/dill/validator_keys, if you want to restore it on another machine
```
------

## Staking
- First, get faucet into your wallet from the Andes channel. Use a different wallet than the one you created in Node and remember that you can only receive faucet once ($request xxxxx)

- visit https://staking.dill.xyz/

![image](https://github.com/user-attachments/assets/ede3c2bf-8687-413d-a766-ed33cf76a41a)

- Here you will upload your file with deposit_data-xxxx.json extension. If you want, you can create this file yourself. To do this, you can create and upload a file named deposit_data-xxxx.json with the output you receive using this code.
```
cat ./dill/validator_keys/deposit_data-xxxx.json
```

- After uploading the deposit_data-xxxx.json file to the site, click Connect to MetaMask, make sure you have enough funds (>2500 DILL)

![image](https://github.com/user-attachments/assets/8a18d6f7-41cb-49b5-9a1d-a74063598d11)

- Send deposit, using MetaMask to send a deposit transaction

![image](https://github.com/user-attachments/assets/8d9ca2aa-3458-4705-a37e-56509d279894)

- Yes, that's all. After these operations, you can check it with your public key (prefixed with 0x) on the last pages in the validators section in Explorer. It may take 1~2 hours to appear

------