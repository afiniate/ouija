ORGANIZATION:=afiniate
NAME:=ouija
LICENSE:="OSI Approved :: Apache Software License v2.0"
AUTHOR:="Afiniate, Inc."
HOMEPAGE:="https://github.com/afiniate/ouija"

DEV_REPO:="git@github.com:afiniate/ouija.git"
BUG_REPORTS:="https://github.com/afiniate/ouija/issues"

DESC_FILE:=$(CURDIR)/description

BUILD_DEPS:=vrt
DEPS:=core async async_unix async_shell cohttp atdgen sexplib cryptokit


vrt.mk:
	vrt prj gen-mk

-include vrt.mk
