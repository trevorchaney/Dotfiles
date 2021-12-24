##
# @file Makefile
# @author Trevor Chaney (tlc) (trevorchaney@gmail.com)
# @date
# @brief

.SILENT: clean
.PHONY: all clean

## Make flags
# MAKEFLAGS := --jobs=$(shell nproc) --output-sync=target --load-average

## Default CXX is g++
# CXX = clang
CXXSPEC = c++03
SHELL = bash

## Use '-m32' to build 32-bit binaries.
CXXFLAGS =-Wall -pipe -std=$(CXXSPEC) #-m32
CFLAGS = $(CXXFLAGS)
LDFLAGS =
LDLIBS = -lstdc++
OPTIMIZATION = -O2 -march=native -mtune=native -flto -fuse-linker-plugin -fdata-sections -ffunction-sections -Wl,--gc-sections

SOURCES = $(wildcard *.cpp)
OBJECTS = $(SOURCES:.cpp=.o)
EXCLUDES =

DEBUG = yes
DEBUGVERBOSE = no
PEDANTIC = yes
PROFILE = yes
PGO = yes

ifeq ($(DEBUG), yes)
ifeq ($(DEBUGVERBOSE), yes)
	CXXFLAGS += -DDEBUGLOGGING
endif
	CXXFLAGS += -ggdb3
	OPTIMIZATION = -O0
endif

ifeq ($(PEDANTIC), yes)
	CXXFLAGS += -Wpedantic
endif

ifeq ($(PROFILE), yes)
ifeq ($(PGO), yes)
ifneq ($(wildcard *.gcda), )
	CXXFLAGS += -fprofile-use
else
	CXXFLAGS += -fprofile-generate
endif
endif
## Use '-p' for prof and '-pg' for gprof
	CXXFLAGS += -pg
endif

CXXFLAGS += $(OPTIMIZATION)


#==============================================================================
# ░▀█▀░█▀█░█▀▄░█▀▀░█▀▀░▀█▀░█▀▀
# ░░█░░█▀█░█▀▄░█░█░█▀▀░░█░░▀▀█
# ░░▀░░▀░▀░▀░▀░▀▀▀░▀▀▀░░▀░░▀▀▀
#==============================================================================

all: project
	@echo MAKEFLAGS: $(MAKEFLAGS)

project: $(OBJECTS)
	$(CXX) $(OBJECTS) $(CXXFLAGS) $(LDFLAGS) $(LDLIBS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

shared: $(OBJECTS)
	$(CXX) $(OBJECTS) $(CXXFLAGS) $(LDLIBS) -shared -o libuc2_msg_factory.so

dox: project
	doxygen .

profile: project
	./a.out
	gprof a.out gmon.out > gprof_profile.out
	prof record ./a.out

mem_analysis: project
	valgrind --leak-check=full --show-reachable=yes --num-callers=20 --track-fds=yes --track-origins=yes -s --log-file="valgrind_analysis.out" ./a.out

static_analysis: project
	cppcheck --enable=all -i $(EXCLUDES) -j $(shell nproc) --std=$(CXXSPEC)

reports: profile static_analysis mem_analysis

clean:
	rm -rf *.out *.gcda *.xml $(OBJECTS) logs dox *.so *.gch core.* obj-lin-*

rebuild: clean all
