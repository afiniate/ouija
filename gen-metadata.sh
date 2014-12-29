#!/bin/bash

set -e

ROOT=$1
BUILD_DIR=$2

VRT="`which vrt`"

VERSION="`$VRT prj semver`"
LIB_NAME=ouija
DESC=`cat descr`

cat <<EOF > $ROOT/opam

opam-version: "1.2"
name: "$LIB_NAME"
version: "VERSION"
maintainer: "contact@afiniate.com"
author: "contact@afiniate.com"
homepage: "https://github.com/afiniate/$LIB_NAME"
bug-reports: "https://github.com/afiniate/$LIB_NAME/issues"
license: "Apache v2"
dev-repo: "git@github.com:afiniate/$LIB_NAME.git"

build: [
  [make "build"]
]

depends: [ "vrt" {build} ]

EOF


cat <<EOF > $BUILD_DIR/META

version = "$VERSION"
description = "$"
requires = ""
archive(byte) = "$LIB_NAME.cma"
archive(byte, plugin) = "$LIB_NAME.cma"
archive(native) = "$LIB_NAME.cmxa"
archive(native, plugin) = "$LIB_NAME.cmxs"
exists_if = "$LIB_NAME.cma"

EOF
