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
SHELL = bash

## Use '-m32' to build 32-bit binaries.
CXXFLAGS =-Wall -pipe
CFLAGS = $(CXXFLAGS)
LDFLAGS =
LDLIBS =
OPTIMIZATION = -O2 -fdata-sections -ffunction-sections -Wl,--gc-sections

SOURCES = $(wildcard *.cpp)
OBJECTS = $(SOURCES:.cpp=.o)

DEBUG = yes
DebugVerbose = no
PEDANTIC = yes
PROFILE = yes

ifeq ($(DEBUG), yes)
ifeq ($(DebugVerbose), yes)
	CXXFLAGS += -ggdb3 -DUC2DEBUG
else
	CXXFLAGS += -ggdb3
endif
	OPTIMIZATION = -O0
endif

ifeq ($(PEDANTIC), yes)
	CXXFLAGS += -Wpedantic
endif

ifeq ($(PROFILE), yes)
	CXXFLAGS += -pg
endif

CXXFLAGS += $(OPTIMIZATION)


#==============================================================================
# ░▀█▀░█▀█░█▀▄░█▀▀░█▀▀░▀█▀░█▀▀
# ░░█░░█▀█░█▀▄░█░█░█▀▀░░█░░▀▀█
# ░░▀░░▀░▀░▀░▀░▀▀▀░▀▀▀░░▀░░▀▀▀
#==============================================================================

all: project

project: $(OBJECTS)
	$(CXX) $(OBJECTS) $(CXXFLAGS) $(LDFLAGS) $(LDLIBS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

shared: $(OBJECTS)
	$(CXX) $(OBJECTS) $(CXXFLAGS) $(LDLIBS) -shared -o libuc2_msg_factory.so

doxy:
	doxygen .

profiles: project
	./a.out
	gprof a.out gmon.out > gprof_profile.out

mem_analysis: project
	valgrind --leak-check=full --show-reachable=yes --num-callers=20 --track-fds=yes --track-origins=yes -s --log-file="valgrind_analysis.out" ./a.out

reports: profiles mem_analysis

clean:
	rm -rf *out* *.o Logs/* html latex *.so *.gch core.* obj-lin-opt

rebuild: clean all
