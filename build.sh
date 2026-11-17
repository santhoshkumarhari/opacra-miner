#!/usr/bin/env bash
# Opacra Miner Standalone Build Script
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"
BUILD_DIR="$DIR/build"
DEPS_DIR="$DIR/deps"

mkdir -p "$BUILD_DIR" "$DEPS_DIR" "$DIR/bin"

# 1. Build libuv dependency if not already present
if [ ! -f "$DEPS_DIR/lib/libuv.a" ]; then
    echo "== Building bundled libuv v1.51.0 =="
    UV_SRC="$DIR/libuv-src"
    if [ ! -d "$UV_SRC" ]; then
        git clone --depth 1 --branch v1.51.0 https://github.com/libuv/libuv "$UV_SRC"
    fi
    mkdir -p "$UV_SRC/build"
    cmake -S "$UV_SRC" -B "$UV_SRC/build" \
        -DCMAKE_BUILD_TYPE=Release \
        -DLIBUV_BUILD_SHARED=OFF \
        -DLIBUV_BUILD_TESTS=OFF \
        -DCMAKE_INSTALL_PREFIX="$DEPS_DIR"
    cmake --build "$UV_SRC/build" -j"$JOBS"
    cmake --install "$UV_SRC/build"
fi

# 2. Configure and build Opacra Miner
echo "== Configuring and building Opacra Miner =="
cmake -S "$DIR" -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_HWLOC=OFF \
    -DWITH_TLS=OFF \
    -DWITH_OPENCL=OFF \
    -DWITH_CUDA=OFF \
    -DWITH_KAWPOW=OFF \
    -DWITH_GHOSTRIDER=OFF \
    -DUV_LIBRARY="$DEPS_DIR/lib/libuv.a" \
    -DUV_INCLUDE_DIR="$DEPS_DIR/include"

cmake --build "$BUILD_DIR" -j"$JOBS"

# 3. Copy output binary to bin/xmrig
if [ -f "$BUILD_DIR/xmrig-notls" ]; then
    cp -f "$BUILD_DIR/xmrig-notls" "$DIR/bin/xmrig"
elif [ -f "$BUILD_DIR/xmrig" ]; then
    cp -f "$BUILD_DIR/xmrig" "$DIR/bin/xmrig"
fi

chmod +x "$DIR/bin/xmrig"
echo "== Build complete! Binary is at $DIR/bin/xmrig =="
"$DIR/bin/xmrig" --version
