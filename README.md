# Opacra Miner (RandomOPCA)

A high-performance standalone CPU miner for **Opacra (OPCA)**, powered by **RandomOPCA** (RandomX with Opacra's custom salt) with integrated support for Opacra's 5% development fund coinbase consensus.

> Based on XMRig v6.26.0 with Opacra's official RandomOPCA patch (`contrib/xmrig/opacra-xmrig.patch`), zero default donation (100% hashrate to miner), and preconfigured solo and pool profiles.

---

## Features

- **RandomOPCA (`rx/opca`) Algorithm Support**: Native support for Opacra's custom RandomX salt (`"RandomOPCA\x01"`).
- **Opacra Consensus Compliant**: Automatically parses Opacra's dual-output coinbase templates (miner reward + 5% dev fund).
- **0% Fee / Donation Level 0**: Configured with 0% developer donation so 100% of your CPU power mines your coins.
- **Cross-Platform**: Run natively on Windows and Linux (or via WSL 2 on Windows).
- **One-Click Launchers**: Interactive scripts (`Start-Mainnet-Mining.bat` & `start-mainnet-mining.sh`) that remember your wallet address and launch mining instantly.

---

## Quick Start

### 1. Solo Mining (Recommended for node operators)

Make sure your Opacra node daemon (`opacrad`) is running:

- **Mainnet**: RPC port `29961`
- **Testnet**: RPC port `29971`

#### On Windows:
Double-click:
- `Start-Mainnet-Mining.bat` (for mainnet)
- `Start-Testnet-Mining.bat` (for testnet)

The script will prompt for your wallet address (starts with `Pa` for mainnet, `Te` for testnet) on first run, save it securely to `mainnet-address.txt`, and start mining against your local node.

#### On Linux / WSL:
```bash
# Mainnet
./start-mainnet-mining.sh

# Testnet
./start-testnet-mining.sh
```

---

### 2. Command Line Usage

#### Solo Mining against your node:
```bash
# Mainnet (solo daemon)
./bin/xmrig -o 127.0.0.1:29961 --daemon -a rx/opca --coin opacra -u Pa<YOUR_MAINNET_ADDRESS>

# Testnet (solo daemon)
./bin/xmrig -o 127.0.0.1:29971 --daemon -a rx/opca --coin opacra -u Te<YOUR_TESTNET_ADDRESS>
```

#### Pool Mining:
```bash
./bin/xmrig -o stratum+tcp://<pool_host>:<port> -a rx/opca -u Pa<YOUR_ADDRESS> -p worker1 -k
```

---

### 3. Configuration via `config.json`

You can edit `config.json` directly to specify your wallet address and pools:

```json
"pools": [
    {
        "algo": "rx/opca",
        "coin": "opacra",
        "url": "127.0.0.1:29961",
        "user": "YOUR_OPACRA_WALLET_ADDRESS",
        "pass": "x",
        "daemon": true
    }
]
```

Run with config:
```bash
./bin/xmrig -c config.json
```

---

## Building from Source

### On Linux or Windows WSL 2 (Ubuntu / Debian):

Prerequisites:
```bash
sudo apt update && sudo apt install -y git build-essential cmake
```

Build:
```bash
./build.sh
```
The script will build the bundled `libuv` dependency statically and compile `bin/xmrig`.

### On Windows (Native MinGW / MSVC):
```cmd
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DWITH_HWLOC=OFF -DWITH_TLS=OFF
cmake --build . --config Release -j4
```

---

## Performance Tuning

1. **Enable Huge Pages**:
   - **Linux / WSL**: `sudo sysctl -w vm.nr_hugepages=1280`
   - **Windows**: Enable "Lock pages in memory" in `secpol.msc` (Local Security Policy) -> User Rights Assignment, then reboot.
2. **Run as Administrator / Root once**:
   - Enables XMRig's MSR (Model-Specific Register) tweaks for Zen/Intel architectures, boosting hashrate by 5-15%.
3. **Thread Count**:
   - RandomX performs best using 1 thread per physical core that has at least 2 MB of L3 cache.
4. **Memory Requirement**:
   - RandomX "fast mode" requires ~2.3 GB of available RAM for the dataset.

---

## License

Based on [XMRig](https://github.com/xmrig/xmrig) (GPL-3.0) and patched for [Opacra](https://github.com/opacra/opacra) (BSD-3-Clause).
