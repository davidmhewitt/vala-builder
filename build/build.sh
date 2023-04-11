#!/bin/bash

set -ex

ROOT=$(pwd)
VERSION=$1

pat='(^[0-9]+\.[0-9]+)'
[[ $VERSION =~ $pat ]]
SHORT_VERSION=${BASH_REMATCH[1]}

FULLNAME=vala-${VERSION}.tar.xz
OUTPUT=$2/${FULLNAME}

REVISION="vala-${VERSION}"
echo "ce-build-revision:${REVISION}"
echo "ce-build-output:${OUTPUT}"

PREFIX_DIR=/opt/compiler-explorer/vala-${VERSION}

curl -sL "https://download.gnome.org/sources/vala/${SHORT_VERSION}/vala-${VERSION}.tar.xz" | tar Jxf -
pushd "vala-${VERSION}"
./configure "--prefix=${PREFIX_DIR}"

make "-j$(nproc)"
make install
popd

# strip executables
find "${PREFIX_DIR}" -type f -perm /u+x -exec strip -d {} \;

export XZ_DEFAULTS="-T 0"
tar Jcf "${OUTPUT}" -C /opt/compiler-explorer .

echo "ce-build-status:OK"
