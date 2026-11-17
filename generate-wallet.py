#!/usr/bin/env python3
"""
Opacra Wallet Generator
Generates a mathematically valid Opacra address (Pa... for mainnet, Te... for testnet)
along with private spend & view keys that can be imported into opacra-wallet-cli.
"""
import secrets
import sys
import os

try:
    from Crypto.Hash import keccak as _keccak
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pycryptodome"])
    from Crypto.Hash import keccak as _keccak

# Curve parameters (ed25519)
Q = 2 ** 255 - 19
L = 2 ** 252 + 27742317777372353535851937790883648493
D = (-121665 * pow(121666, Q - 2, Q)) % Q
I = pow(2, (Q - 1) // 4, Q)

def _xrecover(y):
    xx = (y * y - 1) * pow(D * y * y + 1, Q - 2, Q)
    x = pow(xx, (Q + 3) // 8, Q)
    if (x * x - xx) % Q != 0:
        x = (x * I) % Q
    if x % 2 != 0:
        x = Q - x
    return x

_BY = (4 * pow(5, Q - 2, Q)) % Q
_BX = _xrecover(_BY)
BASE = (_BX, _BY, 1, (_BX * _BY) % Q)

def _add(p, q):
    x1, y1, z1, t1 = p
    x2, y2, z2, t2 = q
    a = (y1 - x1) * (y2 - x2) % Q
    b = (y1 + x1) * (y2 + x2) % Q
    c = t1 * 2 * D * t2 % Q
    dd = z1 * 2 * z2 % Q
    e, f, g, h = b - a, dd - c, dd + c, b + a
    return (e * f % Q, g * h % Q, f * g % Q, e * h % Q)

def _scalarmult(p, e):
    r = (0, 1, 1, 0)
    while e > 0:
        if e & 1:
            r = _add(r, p)
        p = _add(p, p)
        e >>= 1
    return r

def _encode_point(p) -> bytes:
    x, y, z, _ = p
    zi = pow(z, Q - 2, Q)
    x, y = x * zi % Q, y * zi % Q
    return (y | ((x & 1) << 255)).to_bytes(32, "little")

def keccak256(data: bytes) -> bytes:
    k = _keccak.new(digest_bits=256)
    k.update(data)
    return k.digest()

def varint(n: int) -> bytes:
    out = bytearray()
    while True:
        b = n & 0x7F
        n >>= 7
        if n:
            out.append(b | 0x80)
        else:
            out.append(b)
            return bytes(out)

ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
_ENC_BLOCK_SIZES = [0, 2, 3, 5, 6, 7, 9, 10, 11]

def _encode_block(block: bytes) -> str:
    num = int.from_bytes(block, "big")
    size = _ENC_BLOCK_SIZES[len(block)]
    chars = []
    for _ in range(size):
        num, rem = divmod(num, 58)
        chars.append(ALPHABET[rem])
    return "".join(reversed(chars))

def cn_base58_encode(data: bytes) -> str:
    out = []
    for i in range(0, len(data), 8):
        out.append(_encode_block(data[i:i + 8]))
    return "".join(out)

def encode_address(prefix: int, spend_pub: bytes, view_pub: bytes) -> str:
    body = varint(prefix) + spend_pub + view_pub
    return cn_base58_encode(body + keccak256(body)[:4])

def gen_wallet(testnet=False):
    prefix = 8479 if testnet else 30598
    # Random secret spend key
    spend_sec = secrets.randbelow(L - 1) + 1
    # Random secret view key (Monero standard: separate scalar or H(spend_sec) mod L)
    view_sec = secrets.randbelow(L - 1) + 1

    spend_pub = _encode_point(_scalarmult(BASE, spend_sec))
    view_pub = _encode_point(_scalarmult(BASE, view_sec))
    addr = encode_address(prefix, spend_pub, view_pub)

    return {
        "network": "testnet" if testnet else "mainnet",
        "address": addr,
        "spend_key": spend_sec.to_bytes(32, "little").hex(),
        "view_key": view_sec.to_bytes(32, "little").hex()
    }

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Opacra Wallet Generator")
    parser.add_argument("--testnet", action="store_true", help="Generate a testnet address (starts with Te)")
    args = parser.parse_args()

    w = gen_wallet(testnet=args.testnet)
    print("=================================================================")
    print(f"Generated Opacra {w['network'].upper()} Wallet")
    print("=================================================================")
    print(f"Address:            {w['address']}")
    print(f"Secret Spend Key:   {w['spend_key']}")
    print(f"Secret View Key:    {w['view_key']}")
    print("=================================================================")
    print("KEEP YOUR SECRET KEYS SAFE! Anyone with your spend key can spend your coins.")
    print("You can import these keys into opacra-wallet-cli using:")
    print("  opacra-wallet-cli --generate-from-keys mywallet")
    print("=================================================================")
