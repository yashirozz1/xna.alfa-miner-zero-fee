#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
[[ $(uname -s) == Linux && $(uname -m) == x86_64 ]] || {
    printf 'Build target: Linux x86_64.\n' >&2; exit 1;
}
git rev-parse --verify HEAD >/dev/null
if [[ -n $(git status --porcelain --untracked-files=normal) ]]; then
    printf 'Commit source changes before packaging.\n' >&2
    exit 1
fi

# The upstream scripts pin libuv 1.51.0, hwloc 2.12.1 and OpenSSL 3.0.16.
# Invoke with -e explicitly because their shebang is not used by bash script.sh.
(
    cd scripts
    bash -e build.uv.sh
    bash -e build.hwloc.sh
    bash -e build.openssl3.sh
)
cmake -S . -B build/linux -DCMAKE_BUILD_TYPE=Release \
    -DXMRIG_DEPS="$PWD/scripts/deps" -DOPENSSL_USE_STATIC_LIBS=ON \
    -DWITH_CUDA=OFF -DWITH_OPENCL=OFF -DWITH_MSR=OFF
cmake --build build/linux --parallel "${BUILD_JOBS:-4}"
python3 ci/check-linux.py build/linux/alfa-miner-cpu

package=alfa-miner-cpu-6.26.0-zero-fee-linux-x64
mkdir -p "build/linux/package/$package/licenses" dist/linux
install -m 755 build/linux/alfa-miner-cpu "build/linux/package/$package/alfa-miner-cpu"
install -m 644 LICENSE NOTICE.md README.md "build/linux/package/$package/"
install -m 644 scripts/build/libuv-v1.51.0/LICENSE "build/linux/package/$package/licenses/libuv.txt"
install -m 644 scripts/build/hwloc-2.12.1/COPYING "build/linux/package/$package/licenses/hwloc.txt"
install -m 644 scripts/build/openssl-3.0.16/LICENSE.txt "build/linux/package/$package/licenses/openssl.txt"
{
    printf 'Source commit: '; git rev-parse HEAD
    printf 'Build distribution: '; . /etc/os-release; printf '%s\n' "$PRETTY_NAME"
    printf 'Architecture: '; uname -m
    printf '\nSource archive checksums for the statically linked dependencies:\n'
    sha256sum scripts/build/v1.51.0.tar.gz scripts/build/hwloc-2.12.1.tar.gz scripts/build/openssl-3.0.16.tar.gz
    printf '\nRuntime library dependencies:\n'
    ldd build/linux/alfa-miner-cpu
} > "build/linux/package/$package/BUILD-INFO.txt"
tar -czf "dist/linux/$package.tar.gz" -C build/linux/package "$package"
git archive --format=tar.gz --prefix=alfa-miner-cpu-source/ \
    --output=dist/linux/alfa-miner-cpu-6.26.0-zero-fee-source.tar.gz HEAD
(
    cd dist/linux
    sha256sum "$package.tar.gz" alfa-miner-cpu-6.26.0-zero-fee-source.tar.gz > SHA256SUMS.txt
    cat SHA256SUMS.txt
)
