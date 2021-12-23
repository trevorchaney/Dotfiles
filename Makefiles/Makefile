##
# @file Makefile
# @author Trevor Chaney (tlc) (trevor.chaney@ultra-ats.com)
# @version 0.1
# @date Mon  19 13:19:42 CDT 2021
# @brief Gnu Make variables and targets for building the UC2 MessageFactory.

.SILENT: clean
.PHONY: all clean

## Make flags
# MAKEFLAGS := --jobs=$(shell nproc) --output-sync=target --load-average

# Default CXX is g++
# CXX = clang
CXXSPEC = c++03
SHELL = bash

## Use '-m32' to build 32-bit binaries.
CXXFLAGS =-Wall -pipe -std=$(CXXSPEC)
CFLAGS = $(CXXFLAGS)
LDFLAGS =
LDLIBS =
OPTIMIZATION = -O3 -march=native -mtune=native -flto -fuse-linker-plugin -fdata-sections -ffunction-sections -Wl,--gc-sections

SOURCES = $(wildcard *.cpp)
OBJECTS = $(SOURCES:.cpp=.o)
EXCLUDES =

DEBUG = yes
DEBUGVERBOSE = no
PEDANTIC = yes
PROFILE = yes

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
ifneq ($(wildcard *.gcda), )
	CXXFLAGS += -fprofile-use
else
	CXXFLAGS += -fprofile-generate
endif
endif
	# CXXFLAGS += -p # Use '-p' for prof and '-pg' for gprof
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

reports: profiles mem_analysis static_analysis

clean:
	rm -rf *.out *.o Logs/* html latex *.so *.gch core.* obj-lin-*

rebuild: clean all
