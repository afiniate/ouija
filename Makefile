ORGANIZATION:=afiniate
NAME:=ouija
LICENSE:="OSI Approved :: Apache Software License v2.0"
AUTHOR:="Afiniate, Inc."
HOMEPAGE:="https://github.com/afiniate/ouija"

DEV_REPO:="git@github.com:afiniate/ouija.git"
BUG_REPORTS:="https://github.com/afiniate/ouija/issues"

DESC_FILE:=$(CURDIR)/description

OCAML_DEPS:=core async oUnit

trv.mk:
	trv build gen-mk

-include trv.mk
