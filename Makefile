NAME:=ouija
LICENSE:="OSI Approved :: Apache Software License v2.0"
AUTHOR:="Afiniate, Inc."
HOMEPAGE:="https://github.com/afiniate/ouija"

DEV_REPO:="git@github.com:afiniate/ouija.git"
BUG_REPORTS:="https://github.com/afiniate/ouija/issues"

DESC:="Ouija is a path resolution library for ocaml"

BUILD_DEPS:=core async sentinel vrt
DEPS:=

vrt.mk:
	vrt prj gen-mk

-include vrt.mk
