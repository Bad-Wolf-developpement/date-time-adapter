#!/bin/bash -e

# Setup environment for building inside Dockerized toolchain
[ $(id -u) = 0 ] && umask 0

version=$(grep version package.json | cut -d: -f2 | cut -d\" -f2)

if [ -z "${ADDON_ARCH}" ]; then
    TARFILE_SUFFIX=
else
    PYTHON_VERSION="$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d. -f 1-2)"
    TARFILE_SUFFIX="-${ADDON_ARCH}-v${PYTHON_VERSION}"
fi

# Clean up from previous releases
rm -rf *.tgz package
rm -f SHA256SUMS
rm -rf lib

# Prep new package
mkdir lib
mkdir package

# Pull down Python dependencies
pip3 install -r requirements.txt -t lib --no-binary :all: --prefix ""

# Put package together
#cp -r lib pkg LICENSE README.md package.json *.py package/
cp -r lib pkg LICENSE README.md package.json manifest.json *.py package/
find package -type f -name '*.pyc' -delete
find package -type d -empty -delete

# Generate checksums
cd package
sha256sum *.py pkg/*.py *.json README.md LICENSE > SHA256SUMS
find lib -type f -exec sha256sum {} \; >> SHA256SUMS
cd -

# Make the tarball
TARFILE="date-time-adapter-${version}${TARFILE_SUFFIX}.tgz"
tar czf ${TARFILE} package

shasum --algorithm 256 ${TARFILE} > ${TARFILE}.sha256sum
