#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

ADDR_FILE="$DIR/mainnet-address.txt"

if [ ! -f "$ADDR_FILE" ]; then
    read -rp "Paste your Opacra mainnet wallet address (starts with Pa): " ADDR
    echo "$ADDR" > "$ADDR_FILE"
fi

ADDR="$(cat "$ADDR_FILE" | tr -d '[:space:]')"

if [[ ! "$ADDR" =~ ^P[0-9A-Za-z]+ ]]; then
    echo "Error: Invalid Opacra mainnet address in $ADDR_FILE. It must start with Pa."
    rm -f "$ADDR_FILE"
    exit 1
fi

BIN="$DIR/bin/xmrig"
if [ ! -f "$BIN" ]; then
    BIN="$DIR/build/xmrig-notls"
fi

if [ ! -f "$BIN" ]; then
    echo "Binary not found. Running ./build.sh..."
    ./build.sh
    BIN="$DIR/bin/xmrig"
fi

echo "======================================================="
echo "Starting Opacra Miner (RandomOPCA) on Mainnet"
echo "Mining address: $ADDR"
echo "Daemon: 127.0.0.1:29961"
echo "======================================================="

"$BIN" -o 127.0.0.1:29961 --daemon -a rx/opca --coin opacra -u "$ADDR" "$@"
