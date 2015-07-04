ORGANIZATION:=afiniate
NAME:=ouija
LICENSE:="OSI Approved :: Apache Software License v2.0"
AUTHOR:="Afiniate, Inc."
HOMEPAGE:="https://github.com/afiniate/ouija"

DEV_REPO:="git@github.com:afiniate/ouija.git"
BUG_REPORTS:="https://github.com/afiniate/ouija/issues"

DESC_FILE:=$(CURDIR)/description

OCAML_PKG_DEPS := ocaml findlib camlp4
OCAML_DEPS:=core async sentinel
DEPS := trv vrt

trv.mk:
	trv build gen-mk

-include trv.mk
