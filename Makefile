# Copyright 2013 Afiniate All Rights Reserved.
#
# You can control some aspects of the build with next variables (e.g.
# make VARIABLE_NAME="some-value")
#
#  * PARALLEL_JOBS=N let ocamlbuild run N jobs in parallel. The recommended
#    value is the number of cores of your machine. Note that we don't want to
#    use make's own parallel flag (-j), as it will spawn several ocamlbuild jobs
#    competing with each other
#  * BUILD_FLAGS flags used to compile non production ocaml code (e.g tools,
#    tests ...)
#  * BUILD_PROD_FLAGS flags used to compile production ocaml code
#
# =============================================================================
# VARS
# =============================================================================
BUILD_DIR := $(CURDIR)/_build

PREFIX := /usr

TEST_RUN_SRCS := $(shell find $(CURDIR)/src -name "*_tests_run.ml")
TEST_RUN_CMDS := $(notdir $(TEST_RUN_SRCS:%.ml=%))
TEST_RUN_TARGETS:= $(addprefix run-, $(TEST_RUN_CMDS))

### Knobs
PARALLEL_JOBS ?= 2
BUILD_FLAGS ?= -use-ocamlfind -cflags -bin-annot -lflags -g

# =============================================================================
# COMMANDS
# =============================================================================

OCAML_CMD := ocaml
OCAML := $(shell which $(OCAML_CMD))

OCC_CMD := ocamlbuild
OCC := $(shell which $(OCC_CMD))

OCF_CMD := ocamlfind
OCF := $(shell which $(OCF_CMD))

BUILD := $(OCC) -j $(PARALLEL_JOBS) -build-dir $(BUILD_DIR) $(BUILD_FLAGS)

# =============================================================================
# Rules to build the system
# =============================================================================

.PHONY: all build rebuild opam install test

.PRECIOUS: %/.d

%/.d:
	mkdir -p $(@D)
	touch $@

all: build

rebuild: clean all

build:
	$(BUILD) ouija.cma ouija.cmx ouija.cmxa ouija.a ouija.cmxs

test:
	$(BUILD) ouija_unit_tests_run.byte
	$(BUILD_DIR)/src/ouija_unit_tests_run.byte

metadata:
	$(CURDIR)/gen-metadata.sh $(CURDIR) $(BUILD_DIR)

install: metadata
	cd $(BUILD_DIR); $(OCF) install ouija META ouija.cmi ouija.cmo ouija.o \
	                                           ouija.cmx ouija.mli ouija.a \
	                                           ouija.cmxa

remove:
	$(OCF) remove ouija

clean:
	rm -rf $(BUILD_DIR)
