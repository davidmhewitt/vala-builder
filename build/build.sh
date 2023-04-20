#!/bin/bash

set -ex

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
mkdir -p "${PREFIX_DIR}"

# "install" libraries and development headers required by the compiler to the prefix
apt-get update && apt-get download libglib2.0-0 libglib2.0-dev libpcre3 libpcre3-dev
find . -type f -name "*.deb" -exec dpkg-deb -x {} "${PREFIX_DIR}" \;

# Strip the /usr prefix from the installed directory structure
cp -R "${PREFIX_DIR}/usr/"* "${PREFIX_DIR}"
rm -rf "${PREFIX_DIR:?}/usr"

# Patch the prefix in the installed pkgconfig files
find . "${PREFIX_DIR}" -type f -name "*.pc" -exec sed -i "s~prefix=/usr~prefix=${PREFIX_DIR}~g" {} \;

curl -sL "https://download.gnome.org/sources/vala/${SHORT_VERSION}/vala-${VERSION}.tar.xz" | tar Jxf -
pushd "vala-${VERSION}"

# We can build without the doc generator to save a bit of space and time
./configure --disable-valadoc "--prefix=${PREFIX_DIR}"

make "-j$(nproc)"
make install
popd

# patchelf claims to run on multiple files *but* if it fails on any one it silently stops and doesn't process anything else...
find "${PREFIX_DIR}" -type f -perm /u+x -exec patchelf --set-rpath '$ORIGIN/../lib:$ORIGIN/../lib/x86_64-linux-gnu/:$ORIGIN/../lib/vala-'"${SHORT_VERSION}" {} \;

# strip executables
find "${PREFIX_DIR}" -type f -perm /u+x -exec strip -d {} \;

export XZ_DEFAULTS="-T 0"
tar Jcf "${OUTPUT}" -C /opt/compiler-explorer .

echo "ce-build-status:OK"
